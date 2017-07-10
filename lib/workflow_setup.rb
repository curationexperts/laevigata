# Set up the AdminSets and Workflow for Laevigata
require File.expand_path('../../config/environment', __FILE__)
require 'yaml'

# Set up the application's initial state: load required roles, create required AdminSets, load appropriate users and workflows
class WorkflowSetup
  attr_reader :admin_set_owner
  attr_reader :admin_sets_config
  attr_accessor :superusers_config
  ADMIN_SET_OWNER = "admin_set_owner".freeze
  DEFAULT_SUPERUSERS_CONFIG = "#{::Rails.root}/config/emory/superusers.yml".freeze
  DEFAULT_ADMIN_SETS_CONFIG = "#{::Rails.root}/config/emory/admin_sets.yml".freeze

  # Set up the parameters for
  # @param [String] superusers_config a file containing the email addresses of the application's superusers
  # @param [String] config_file_dir the directory where the config files reside
  # @param [String] schools_config
  # @param [String] log_location where should the log files write? Default is STDOUT. /dev/null is also an option for CI builds
  def initialize(superusers_config = DEFAULT_SUPERUSERS_CONFIG, admin_sets_config = DEFAULT_ADMIN_SETS_CONFIG, log_location = STDOUT)
    raise "File #{superusers_config} does not exist" unless File.exist?(superusers_config)
    @superusers_config = YAML.safe_load(File.read(superusers_config))
    raise "File #{admin_sets_config} does not exist" unless File.exist?(admin_sets_config)
    @admin_sets_config = YAML.safe_load(File.read(admin_sets_config))
    @logger = Logger.new(log_location)
    @logger.level = Logger::DEBUG
    @logger.info "Initializing new workflow setup with superusers file #{superusers_config} and admin_sets_config files from #{admin_sets_config}"
    Hyrax::RoleRegistry.new.persist_registered_roles! # Ensure we have a managing and a depositing role
    @admin_set_owner = make_superuser(ADMIN_SET_OWNER)
  end

  # Load the superusers
  # Make an AdminSet for each school, with the proper workflow
  # Allow any registered user to deposit into any of the AdminSets
  # Give superusers every available role in all workflows in all AdminSets
  def setup
    load_superusers
    admin_sets.each do |as|
      @logger.debug "Attempting to make admin set for #{as}"
      make_admin_set_from_config(as)
    end
    everyone_can_deposit_everywhere
    give_superusers_superpowers
  end

  # Make an AdminSet and assign it a one step mediated deposit workflow
  # @param [String] admin_set_title The title of the admin set to create
  # @param [String] workflow_name The name of the mediated deposit workflow to enable
  def make_mediated_deposit_admin_set(admin_set_title, workflow_name = "emory_one_step_approval")
    a = make_admin_set(admin_set_title)
    activate_mediated_deposit(a, workflow_name)
    a
  end

  # Given an admin set and a role, return relevant Array of Sipity::Users for the
  # currently active workflow
  # @param [AdminSet] admin_set
  # @param [String|Sipity::Role] role e.g., "approving" "depositing" "managing"
  # @return [Array<Sipity::Agent>] An array of Sipity::Agent objects
  def users_in_role(admin_set, role)
    return [] unless admin_set.permission_template.available_workflows.where(active: true).count > 0
    users_in_role = []
    sipity_role = if role.is_a?(Sipity::Role)
                    role
                  else
                    Sipity::Role.find_by!(name: role)
                  end
    workflow = admin_set.permission_template.available_workflows.where(active: true).first
    wf_role = Sipity::WorkflowRole.find_by(workflow: workflow, role_id: sipity_role)
    return [] unless wf_role
    wf_role.workflow_responsibilities.pluck(:agent_id).each do |agent_id|
      users_in_role << Sipity::Agent.where(id: agent_id).first
    end
    users_in_role
  end

  # Read a config file to figure out what workflow to enable and how to grant approving_role
  # @param [String] admin_set_title
  # @return [AdminSet]
  def make_admin_set_from_config(admin_set_title)
    config = admin_set_config(admin_set_title)
    config["workflow"] || config["workflow"] = "emory_one_step_approval"
    admin_set = make_mediated_deposit_admin_set(admin_set_title, config["workflow"])
    approving_users = []
    config["approving"].each do |approver_ppid|
      u = ::User.find_or_create_by(ppid: approver_ppid)
      u.password = "123456"
      u.save
      approving_users << u.to_sipity_agent
    end
    approval_role = Sipity::Role.find_by!(name: 'approving')
    workflow = admin_set.active_workflow
    workflow.update_responsibilities(role: approval_role, agents: (approving_users.concat users_in_role(admin_set, "approving")))
    if workflow.workflow_roles.map { |workflow_role| workflow_role.role.name }.include?("reviewing")
      reviewing_role = Sipity::Role.find_by!(name: 'reviewing')
      workflow.update_responsibilities(role: reviewing_role, agents: (approving_users.concat users_in_role(admin_set, "reviewing")))
    end
    admin_set
  end

  # Create the admin role, or find it if it exists already
  # @return [Role] the admin Role
  def admin_role
    Role.find_or_create_by(name: "admin")
  end

  # Load the superusers from a config file
  def load_superusers
    admin_role.users = [] # Remove all the admin users every time you reload
    admin_role.save
    @superusers_config["superusers"].keys.each do |provider|
      @superusers_config["superusers"][provider].each do |s|
        make_superuser(s, provider)
      end
    end
  end

  # Make a superuser
  # @param [String] the ppid of the superuser
  # @return [User] the superuser who was just created
  def make_superuser(ppid, provider = "database")
    @logger.debug "Making superuser #{ppid}"
    admin_user = ::User.find_or_create_by(ppid: ppid)
    admin_user.password = "123456"
    admin_user.provider = "shibboleth" if provider == "shibboleth"
    admin_user.save
    admin_role.users << admin_user
    admin_role.save
    admin_user
  end

  # return an array of all current superusers
  # @return [Array(User)]
  def superusers
    raise "No superusers are defined" unless admin_role.users.count > 0
    admin_role.users
  end

  # Allow anyone with a registered account to deposit into any of the AdminSets
  def everyone_can_deposit_everywhere
    AdminSet.all.each do |admin_set|
      admin_set.permission_template.access_grants.create(agent_type: 'group', agent_id: 'registered', access: 'deposit')
      deposit = Sipity::Role.find_by!(name: 'depositing')
      admin_set.permission_template.available_workflows.each do |workflow|
        workflow.update_responsibilities(role: deposit, agents: Hyrax::Group.new('registered'))
      end
    end
  end

  # Give superusers the managing role in all AdminSets
  # Also give them all workflow roles for all AdminSets
  def give_superusers_superpowers
    @logger.info "Giving superuser powers to #{superusers.pluck(:ppid)}"
    give_superusers_managing_role
    give_superusers_workflow_roles
  end

  def superusers_as_sipity_agents
    superusers.map(&:to_sipity_agent)
  end

  # Give all superusers the managing role all workflows
  def give_superusers_managing_role
    AdminSet.all.each do |admin_set|
      admin_set.permission_template.available_workflows.each do |workflow| # .where(active: true) ?
        workflow.update_responsibilities(role: Sipity::Role.where(name: "managing").first, agents: superusers_as_sipity_agents)
      end
    end
  end

  def give_superusers_workflow_roles
    AdminSet.all.each do |admin_set|
      admin_set.permission_template.available_workflows.where(active: true).each do |workflow|
        workflow_roles = Sipity::WorkflowRole.where(workflow_id: workflow.id)
        workflow_roles.each do |workflow_role|
          workflow_role_name = Sipity::Role.where(id: workflow_role.role_id).first.name
          next if workflow_role_name == "depositing" || workflow_role_name == "managing"
          union_of_users = superusers_as_sipity_agents.concat(users_in_role(admin_set, workflow_role_name)).uniq
          # neither of these two lines works
          # @logger.debug "Granting #{workflow_role_name} to #{union_of_users.map { |u| User.where(id: u.proxy_for_id).first.user_key }}"
          # @logger.debug "Granting #{workflow_role_name} to #{union_of_users.map { |u| User.where(id: u.proxy_for_id).first.ppid }}"
          workflow.update_responsibilities(role: Sipity::Role.where(id: workflow_role.role_id), agents: union_of_users)
        end
      end
    end
  end

  # Make an AdminSet with the given title, belonging to the @admin_set_owner
  # @return [AdminSet] the admin set that was just created, or the one that existed already
  def make_admin_set(admin_set_title)
    if AdminSet.where(title: admin_set_title).count > 0
      @logger.debug "AdminSet #{admin_set_title} already exists."
      load_workflows # Load workflows even if the AdminSet exists already, in case new workflows have appeared
      return AdminSet.where(title: admin_set_title).first
    end
    a = AdminSet.new
    a.title = [admin_set_title]
    a.save
    Hyrax::AdminSetCreateService.call(admin_set: a, creating_user: @admin_set_owner)
    load_workflows # You must load_workflows after every AdminSet creation
    a
  end

  # Load the workflows from config/workflows
  # Does the same thing as `bin/rails hyrax:workflow:load`
  # Note: You MUST create an AdminSet (and its associated PermissionTemplate first)
  # If you think you have the right AdminSet, but workflows won't load, check that
  # the permission templates didn't get wiped from the database somehow
  def load_workflows
    raise "Can't load workflows without a Permission Template. Do you need to make an AdminSet first?" if Hyrax::PermissionTemplate.all.empty?
    Hyrax::Workflow::WorkflowImporter.load_workflows(logger: @logger)
    errors = Hyrax::Workflow::WorkflowImporter.load_errors
    abort("Failed to process all workflows:\n  #{errors.join('\n  ')}") unless errors.empty?
  end

  # Activate a mediated deposit workflow for the given admin_set.
  # Default is emory_one_step_approval, but a different value can be passed in.
  # The activate! method will DEactivate it if it was already active, so be careful.
  # @return [Boolean] true if successful
  def activate_mediated_deposit(admin_set, workflow_name = "emory_one_step_approval")
    osmd = admin_set.permission_template.available_workflows.where(name: workflow_name).first
    if osmd.active == true
      @logger.debug "AdminSet #{admin_set.title.first} already had workflow #{admin_set.permission_template.available_workflows.where(active: true).first.name}. Not making any changes."
      return true
    end
    Sipity::Workflow.activate!(
      permission_template: admin_set.permission_template,
      workflow_id: osmd.id
    )
    @logger.debug "AdminSet #{admin_set.title.first} has workflow #{admin_set.permission_template.available_workflows.where(active: true).first.name}"
    true
  end

  # Return an array of AdminSets that should be set up for the initial workflow
  # @return [Array(String)]
  def admin_sets
    @admin_sets_config.keys
  end

  # Given the name of a school, read its config into a Hash
  # @param [String] the name of an admin_set
  # @return [Hash] a Hash containing approvers and (optionally) workflow for this school
  def admin_set_config(school_name)
    raise "Couldn't find expected config for #{school_name}" unless @admin_sets_config[school_name]
    @admin_sets_config[school_name]
  end
end

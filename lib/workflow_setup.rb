# Set up the AdminSets and Workflow for Laevigata
require File.expand_path('../../config/environment', __FILE__)
require 'yaml'

# Set up the application's initial state: load required roles, create required AdminSets, load appropriate users and workflows
class WorkflowSetup
  attr_reader :uberadmin
  attr_accessor :superusers_config
  attr_accessor :config_file_dir
  DEFAULT_SUPERUSERS_CONFIG = "#{::Rails.root}/config/emory/superusers.yml".freeze
  DEFAULT_CONFIG_FILE_DIR = "#{::Rails.root}/config/emory/".freeze
  DEFAULT_SCHOOLS_CONFIG = "#{::Rails.root}/config/emory/schools.yml".freeze

  # Set up the parameters for
  # @param [String] superusers_config a file containing the email addresses of the application's superusers
  # @param [String] config_file_dir the directory where the config files reside
  # @param [String] schools_config
  # @param [String] log_location where should the log files write? Default is STDOUT. /dev/null is also an option for CI builds
  def initialize(superusers_config = DEFAULT_SUPERUSERS_CONFIG, config_file_dir = DEFAULT_CONFIG_FILE_DIR, schools_config = DEFAULT_SCHOOLS_CONFIG, log_location = STDOUT)
    @superusers_config = superusers_config
    @config_file_dir = config_file_dir
    @schools_config = schools_config
    @logger = Logger.new(log_location)
    @logger.level = Logger::DEBUG
    @logger.info "Initializing new workflow setup with superusers file #{@superusers_config} and config files from #{@config_file_dir}"
    Hyrax::RoleRegistry.new.persist_registered_roles! # Ensure we have a managing and a depositing role
  end

  # Load the superusers
  # Make an AdminSet for each school, with the proper workflow
  # Allow any registered user to deposit into any of the AdminSets
  # Give superusers every available role in all workflows in all AdminSets
  def setup
    load_superusers
    schools.each do |school|
      @logger.debug "Attempting to make admin set for #{school}"
      make_admin_set_from_config(school)
    end
    everyone_can_deposit_everywhere
    give_superusers_superpowers
  end

  # Make an AdminSet and assign it a one step mediated deposit workflow
  # @param [String] admin_set_title The title of the admin set to create
  # @param [String] workflow_name The name of the mediated deposit workflow to enable
  def make_mediated_deposit_admin_set(admin_set_title, workflow_name = "one_step_mediated_deposit")
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
    config = school_config(admin_set_title)
    config["workflow"] || config["workflow"] = "one_step_mediated_deposit"
    admin_set = make_mediated_deposit_admin_set(admin_set_title, config["workflow"])
    approving_users = []
    config["approving"].each do |approver_email|
      u = ::User.find_or_create_by(email: approver_email)
      u.password = "123456"
      u.save
      approving_users << u.to_sipity_agent
    end
    approval_role = Sipity::Role.find_by!(name: 'approving')
    workflow = admin_set.permission_template.available_workflows.where(active: true).first
    workflow.update_responsibilities(role: approval_role, agents: (approving_users.concat users_in_role(admin_set, "approving")))
    admin_set
  end

  # Create the admin role, or find it if it exists already
  # @return [Role] the admin Role
  def admin_role
    Role.find_or_create_by(name: "admin")
  end

  # Make a superuser
  # @param [String] the email of the superuser
  # @return [User] the superuser who was just created
  def make_superuser(email)
    @logger.debug "Making superuser #{email}"
    admin_user = ::User.find_or_create_by(email: email)
    admin_user.password = "123456"
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

  # Load the superusers from a config file
  def load_superusers
    admin_role.users = [] # Remove all the admin users every time you reload
    admin_role.save
    raise "File #{@superusers_config} does not exist" unless File.exist?(@superusers_config)
    config = YAML.safe_load(File.read(@superusers_config))
    config["superusers"].each do |s|
      make_superuser(s)
    end
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
    @logger.info "Giving superuser powers to #{superusers.pluck(:email)}"
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
          @logger.debug "Granting #{workflow_role_name} to #{union_of_users.map { |u| User.where(id: u.proxy_for_id).first.email }}"
          workflow.update_responsibilities(role: Sipity::Role.where(id: workflow_role.role_id), agents: union_of_users)
        end
      end
    end
  end

  # Check to see if there is an uberadmin defined. If there isn't, throw an
  # exception. If there is, return that user. The uberadmin is the first superuser.
  # @return [User] the uberadmin user
  def uberadmin
    raise "Uberadmin not defined: Cannot create AdminSets" if admin_role.users.empty?
    superusers.first
  end

  # Make an AdminSet with the given title, belonging to the uberadmin
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
    Hyrax::AdminSetCreateService.call(admin_set: a, creating_user: uberadmin)
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

  # Activate the one_step_mediated_deposit workflow for the given admin_set.
  # The activate! method will DEactivate it if it was already active, so be careful.
  # @return [Boolean] true if successful
  def activate_mediated_deposit(admin_set, workflow_name = "one_step_mediated_deposit")
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

  # Return an array of schools that should be set up for the initial workflow
  # @return [Array(String)]
  def schools
    @logger.debug "Loading schools.yml file #{@schools_config}"
    config = YAML.safe_load(File.read(@schools_config))
    config["schools"].keys
  end

  # Given the name of a school, read its config file into a Hash
  # @param [String] the name of a school
  # @return [Hash] a Hash containing approvers and depositors for this school
  def school_config(school_name)
    YAML.safe_load(File.read("#{@config_file_dir}#{school_name.downcase.tr(' ', '_')}.yml"))
  rescue
    raise "Couldn't find expected config #{@config_file_dir}#{school_name.downcase.tr(' ', '_')}.yml"
  end
end

# Set up the AdminSets and Workflow for Laevigata
require File.expand_path('../../config/environment', __FILE__)
require 'yaml'

class WorkflowSetup
  attr_reader :uberadmin
  attr_accessor :superusers_config
  SCHOOLS_CONFIG = "#{::Rails.root}/config/emory/schools.yml".freeze

  def initialize
    @superusers_config = "#{::Rails.root}/config/emory/superusers.yml"
  end

  # Load the superusers
  # Make an AdminSet for each school, with the proper workflow
  # Allow any registered user to deposit into any of the AdminSets
  # Give superusers every available role in all workflows in all AdminSets
  def setup
    load_superusers
    schools.each do |school|
      make_mediated_deposit_admin_set(school)
    end
    everyone_can_deposit_everywhere
    give_superusers_superpowers
  end

  # Make an AdminSet and assign it a one step mediated deposit workflow
  def make_mediated_deposit_admin_set(admin_set_title)
    a = make_admin_set(admin_set_title)
    activate_mediated_deposit(a)
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
      deposit = Sipity::Role.find_by_name!('depositing')
      admin_set.permission_template.available_workflows.each do |workflow|
        workflow.update_responsibilities(role: deposit, agents: Hyrax::Group.new('registered'))
      end
    end
  end

  # Give all superusers power in all roles in all workflows
  def give_superusers_superpowers
    superusers_as_sipity_agents = superusers.map(&:to_sipity_agent)
    AdminSet.all.each do |admin_set|
      admin_set.permission_template.available_workflows.each do |workflow| # .where(active: true) ?
        Sipity::Role.all.each do |role|
          workflow.update_responsibilities(role: role, agents: superusers_as_sipity_agents)
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
    return AdminSet.where(title: admin_set_title).first unless AdminSet.where(title: admin_set_title).empty?
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
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    Hyrax::Workflow::WorkflowImporter.load_workflows(logger: logger)
    errors = Hyrax::Workflow::WorkflowImporter.load_errors
    abort("Failed to process all workflows:\n  #{errors.join('\n  ')}") unless errors.empty?
  end

  # Activate the one_step_mediated_deposit workflow for the given admin_set
  # @return [Boolean] true if successful
  def activate_mediated_deposit(admin_set)
    osmd = admin_set.permission_template.available_workflows.where(name: "one_step_mediated_deposit").first
    Sipity::Workflow.activate!(
      permission_template: admin_set.permission_template,
      workflow_id: osmd.id
    )
  end

  # Return an array of schools that should be set up for the initial workflow
  # @return [Array(String)]
  def schools
    config = YAML.safe_load(File.read(SCHOOLS_CONFIG))
    config["schools"].keys
  end
end

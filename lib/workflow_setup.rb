# Set up the AdminSets and Workflow for Laevigata
class WorkflowSetup

  attr_reader :uberadmin

  # Demo setup: Fake values hard coded just to get something working
  def demo_setup
    make_uberadmin("bess@curationexperts.com")
    make_mediated_deposit_admin_set("School of Hard Knocks")
  end

  # Make an AdminSet and assign it a one step mediated deposit workflow
  def make_mediated_deposit_admin_set(admin_set_title)
    make_uberadmin("bess@curationexperts.com")
    a = make_admin_set(admin_set_title)
    activate_mediated_deposit(a)
  end

  # Create the admin role, or find it if it exists already
  # @return [Role] the admin Role
  def admin_role
    Role.find_or_create_by(name: "admin")
  end

  # The Sipity::Role used to allow a user to deposit in a workflow
  # @return [Sipity::Role]
  def depositing_role
    raise "Expected Sipity::Role 'depositing' not found: Do you need to load workflows?" unless Sipity::Role.where(name: "depositing").first
    Sipity::Role.where(name: "depositing").first
  end

  # The Sipity::Role used to allow a user to approve in a workflow
  # @return [Sipity::Role]
  def approving_role
    raise "Expected Sipity::Role 'approving' not found: Do you need to load workflows?" unless Sipity::Role.where(name: "approving").first
    Sipity::Role.where(name: "approving").first
  end

  # Make an uber admin account. The first uberadmin will own all the admin sets
  # @param [String] uberadmin_email The email to use for the uberadmin account
  # @return [User] the uberadmin user
  def make_uberadmin(uberadmin_email)
    admin_user = User.find_or_create_by(email: uberadmin_email)
    # TODO: How will the uberadmin authenticate? This needs re-writing to work with shibboleth
    admin_user.password = "123456"
    admin_user.save
    admin_role.users = []
    admin_role.users << admin_user
    admin_role.save
    @uberadmin = admin_user
    @uberadmin
  end

  # Check to see if there is an uberadmin defined. If there isn't, throw an
  # exception. If there is, return that user.
  # @return [User] the uberadmin user
  def uberadmin
    raise "Uberadmin not defined: Cannot create AdminSets" if admin_role.users.empty?
    admin_role.users.first
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
end

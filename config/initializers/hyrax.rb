# coding: utf-8
Hyrax.config do |config|
  # Injected via `rails g hyrax:work Etd`
  config.register_curation_concern :etd
  # Register roles that are expected by your implementation.
  # @see Hyrax::RoleRegistry for additional details.
  # @note there are magical roles as defined in Hyrax::RoleRegistry::MAGIC_ROLES
  # config.register_roles do |registry|
  #   registry.add(name: 'captaining', description: 'For those that really like the front lines')
  # end

  # When an admin set is created, we need to activate a workflow.
  # The :default_active_workflow_name is the name of the workflow we will activate.
  # @see Hyrax::Configuration for additional details and defaults.
  # config.default_active_workflow_name = 'default'

  # Email recipient of messages sent via the contact form
  # config.contact_email = "repo-admin@example.org"

  # Text prefacing the subject entered in the contact form
  # config.subject_prefix = "Contact form:"

  # How many notifications should be displayed on the dashboard
  # config.max_notifications_for_dashboard = 5

  # How frequently should a file be audited
  # config.max_days_between_audits = 7

  # Enable displaying usage statistics in the UI
  # Defaults to false
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  # config.analytics = false

  # Google Analytics tracking ID to gather usage statistics
  # config.google_analytics_id = 'UA-99999999-1'

  # Date you wish to start collecting Google Analytic statistics for
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  # config.analytic_start_date = DateTime.new(2014, 9, 10)

  # Enables a link to the citations page for a work
  # Default is false
  # config.citations = false

  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

  # Hostpath to be used in Endnote exports
  # config.persistent_hostpath = 'http://localhost/files/'

  # If you have ffmpeg installed and want to transcode audio and video uncomment this line
  config.enable_ffmpeg = true

  # Hyrax uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  # config.enable_noids = true

  # Template for your repository's NOID IDs
  # config.noid_template = ".reeddeeddk"

  # Use the database-backed minter class
  config.noid_minter_class = Noid::Rails::Minter::Db

  # Store identifier minter's state in a file for later replayability
  # config.minter_statefile = '/tmp/minter-state'

  # Prefix for Redis keys
  config.redis_namespace = "laevigata_#{Rails.env}"

  # Path to the file characterization tool
  config.fits_path = "fits"

  # Path to the file derivatives creation tool
  config.libreoffice_path = "soffice"

  # Option to enable/disable full text extraction from PDFs
  # Default is true, set to false to disable full text extraction
  config.extract_full_text = false

  # How many seconds back from the current time that we should show by default of the user's activity on the user's dashboard
  # config.activity_to_show_default_seconds_since_now = 24*60*60

  # Hyrax can integrate with Zotero's Arkivo service for automatic deposit
  # of Zotero-managed research items.
  # config.arkivo_api = false

  # Location autocomplete uses geonames to search for named regions
  # Username for connecting to geonames
  # config.geonames_username = ''

  # Should the acceptance of the licence agreement be active (checkbox), or
  # implied when the save button is pressed? Set to true for active
  # The default is true.
  # config.active_deposit_agreement_acceptance = true

  # Should work creation require file upload, or can a work be created first
  # and a file added at a later time?
  # The default is true.
  # config.work_requires_files = true

  # Should a button with "Share my work" show on the front page to all users (even those not logged in)?
  # config.always_display_share_button = true

  # The user who runs batch jobs. Update this if you aren't using emails
  # config.batch_user_key = 'batchuser@example.com'

  # The user who runs audit jobs. Update this if you aren't using emails
  # config.audit_user_key = 'audituser@example.com'
  #
  # The banner image. Should be 5000px wide by 1000px tall
  # config.banner_image = 'https://cloud.githubusercontent.com/assets/92044/18370978/88ecac20-75f6-11e6-8399-6536640ef695.jpg'

  # Temporary paths to hold uploads before they are ingested into FCrepo
  # These must be lambdas that return a Pathname. Can be configured separately
  config.upload_path = ->() { Pathname.new(ENV['UPLOAD_PATH'] || '/opt/uploads') }
  config.cache_path = ->() { Pathname.new(ENV['CACHE_PATH'] || '/opt/uploads/cache') }

  # Location on local file system where derivatives will be stored
  # If you use a multi-server architecture, this MUST be a shared volume
  config.derivatives_path = ENV['DERIVATIVES_PATH'] || '/opt/derivatives'

  # Should schema.org microdata be displayed?
  # config.display_microdata = true

  # What default microdata type should be used if a more appropriate
  # type can not be found in the locale file?
  # config.microdata_default_type = 'http://schema.org/CreativeWork'

  # Location on local file system where uploaded files will be staged
  # prior to being ingested into the repository or having derivatives generated.
  # If you use a multi-server architecture, this MUST be a shared volume.
  config.working_path = ENV['WORKING_PATH'] || '/opt/uploads'

  # Should the media display partial render a download link?
  config.display_media_download_link = false

  # A configuration point for changing the behavior of the license service
  #   @see Hyrax::LicenseService for implementation details
  # config.license_service_class = Hyrax::LicenseService

  # Labels for permission levels
  # config.permission_levels = { "Choose Access" => "none", "View/Download" => "read", "Edit" => "edit" }

  # Labels for owner permission levels
  # config.owner_permission_levels = { "Edit Access" => "edit" }

  # Returns a lambda that takes a hash of attributes and returns a string of the model
  # name. This is called by the batch upload process
  # config.model_to_create = ->(_attributes) { Hyrax.primary_work_type.model_name.name }

  # Path to the ffmpeg tool
  config.ffmpeg_path = 'ffmpeg'

  # Max length of FITS messages to display in UI
  # config.fits_message_length = 5

  # ActiveJob queue to handle ingest-like jobs
  config.ingest_queue_name = :default

  ## Attributes for the lock manager which ensures a single process/thread is mutating a ore:Aggregation at once.
  # How many times to retry to acquire the lock before raising UnableToAcquireLockError
  # config.lock_retry_count = 600 # Up to 2 minutes of trying at intervals up to 200ms
  #
  # Maximum wait time in milliseconds before retrying. Wait time is a random value between 0 and retry_delay.
  # config.lock_retry_delay = 200
  #
  # How long to hold the lock in milliseconds
  # config.lock_time_to_live = 60_000

  ## Do not alter unless you understand how ActiveFedora handles URI/ID translation
  # config.translate_id_to_uri = ActiveFedora::Noid.config.translate_id_to_uri
  # config.translate_uri_to_id = ActiveFedora::Noid.config.translate_uri_to_id

  ## Fedora import/export tool
  #
  # Path to the Fedora import export tool jar file
  # config.import_export_jar_file_path = "tmp/fcrepo-import-export.jar"
  #
  # Location where descriptive rdf should be exported
  # config.descriptions_directory = "tmp/descriptions"
  #
  # Location where binaries are exported
  # config.binaries_directory = "tmp/binaries"

  # If browse-everything has been configured, load the configs.  Otherwise, set to nil.
  begin
    if defined? BrowseEverything
      config.browse_everything = BrowseEverything.config
    else
      Rails.logger.warn "BrowseEverything is not installed"
    end
  rescue Errno::ENOENT
    config.browse_everything = nil
  end
end

Date::DATE_FORMATS[:standard] = "%m/%d/%Y"

Qa::Authorities::Local.register_subauthority('subjects', 'Qa::Authorities::Local::TableBasedAuthority')
Qa::Authorities::Local.register_subauthority('languages', 'Qa::Authorities::Local::TableBasedAuthority')
Qa::Authorities::Local.register_subauthority('genres', 'Qa::Authorities::Local::TableBasedAuthority')

Hyrax::EmbargoPresenter.class_eval do
  def sortable_release_date
    return solr_document.embargo_release_date&.iso8601 unless
      method(__method__).super_method

    warn "#{self.class}##{__method__} has been implemented in Hyrax and can be removed."
    super
  end
end

Hyrax::CurationConcern.class_eval do
  def self.actor(*args)
    @work_middleware_stack ||= actor_factory.build(Hyrax::Actors::Terminator.new)
    return @work_middleware_stack if args.empty?

    warn "[DEPRECATION] calling `CurationConcern.actor` with arguments is " \
         "deprecated and removed from Hyrax 2.0.0. Pass a " \
         "`Hyrax::Actors::Environment` to `#create`, `#update` or `#delete` " \
         "instead.\nCalled from #{Gem.location_of_caller.join(':')}"

    concern, ability = args.take(2)
    Hyrax::Actors::ActorStack.new(concern, ability, @work_middleware_stack)
  end
end

module Hyrax
  module Actors
    class ActorStack
      def initialize(work, ability, actor)
        warn "[DEPRECATION] caling `Hyrax::Actors::ActorStack` is deprecated " \
             "and removed from from Hyrax 2.0.0. Use " \
             "`Hyrax::DefaultMiddlewareStack` instead.\n " \
             "Called from #{Gem.location_of_caller.join(':')}"

        @ability = ability
        @actor   = actor
        @work    = work

        return unless @actor.respond_to? :each

        stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
          @actor.each { |a| middleware.use(a) }
        end

        @actor = stack.build(Hyrax::Actors::Terminator.new)
      end

      def create(*args)
        return @actor.create(args.first) if
          args.first.is_a? Hyrax::Actors::Environment

        @actor.create Hyrax::Actors::Environment.new(@work, @ability, args.first)
      end

      def update(*args)
        return @actor.update(args.first) if
          args.first.is_a? Hyrax::Actors::Environment

        @actor.update Hyrax::Actors::Environment.new(@work, @ability, args.first)
      end

      def destroy(*args)
        return @actor.destroy(args.first) if
          args.first.is_a? Hyrax::Actors::Environment

        @actor.destroy Hyrax::Actors::Environment.new(@work, @ability, args.first)
      end
    end
  end
end

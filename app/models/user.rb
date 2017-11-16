class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :ppid, :email, :password, :password_confirmation
  end

  # this is fixing a strange bug, we never store anyone's shibboleth password
  if Hyrax::CreateWithRemoteFilesActor.needs_attr_accessible?
    attr_reader :password
  end

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # Include devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # remove :database_authenticatable in production, remove :validatable to integrate with Shibboleth
  devise_modules = [:omniauthable, :rememberable, :trackable, omniauth_providers: [:shibboleth], authentication_keys: [:uid]]
  devise_modules.prepend(:database_authenticatable) if AuthConfig.use_database_auth?
  devise *devise_modules

  # When a user authenticates via shibboleth, find their User object or make
  # a new one. Populate it with data we get from shibboleth.
  # @param [OmniAuth::AuthHash] auth
  def self.from_omniauth(auth)
    Rails.logger.debug "auth = #{auth.inspect}"
    # Uncomment the debugger above to capture what a shib auth object looks like for testing
    user = where(provider: auth.provider, uid: auth.info.uid).first_or_create
    user.display_name = auth.info.display_name
    user.uid = auth.info.uid
    user.ppid = auth.uid
    user.email = auth.info.uid + '@emory.edu'
    user.save
    user
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    uid
  end

  # Mailboxer (the notification system) needs the User object to respond to this method
  # in order to send emails
  def mailboxer_email(_object)
    email
  end
end

class User < ApplicationRecord
  # Special error for when Shibboleth passes us
  # incomplete user data
  class NilShibbolethUserError < RuntimeError
    attr_accessor :auth

    def initialize(message = nil, auth = nil)
      super(message)
      self.auth = auth
    end
  end

  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  # this is fixing a strange bug, we never store anyone's shibboleth password
  if Hyrax::Actors::CreateWithRemoteFilesActor.needs_attr_accessible?
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
  # a new one. Populate it with data we get from shibboleth. If shibboleth
  # doesn't pass us all the info we need to make a User object, do not make
  # blank one. Usually if the user just tries to log in again it will work.
  # @param [OmniAuth::AuthHash] auth
  # @example auth = #<OmniAuth::AuthHash /
  #                   credentials=#<OmniAuth::AuthHash> /
  #                   extra=#<OmniAuth::AuthHash /
  #                   raw_info=#<OmniAuth::AuthHash>> /
  #                   info=#<OmniAuth::AuthHash::InfoHash /
  #                          display_name="Test User" /
  #                          name="User, Test" /
  #                          uid="tuser"> /
  #                   provider="shibboleth" /
  #                   uid="P8675309">
  # @note auth.uid contains the Emory PPID auth.info.uid contains the login name (i.e. NetID)
  # @note laevigata uses the PPID for the devise user_key (instead of the NetID)
  def self.from_omniauth(auth)
    Rails.logger.debug "auth = #{auth.inspect}"
    raise User::NilShibbolethUserError.new("No uid", auth) if auth.uid.empty? || auth.info.uid.empty?
    user = User.find_or_initialize_by(provider: auth.provider, uid: auth.info.uid)
    user.assign_attributes(display_name: auth.info.display_name, ppid: auth.uid)
    # tezprox@emory.edu isn't a real email address
    user.email = auth.info.uid + '@emory.edu' unless auth.info.uid == 'tezprox'
    user.save
    user
  rescue User::NilShibbolethUserError => e
    Honeybadger.notify "Nil user detected: Shibboleth didn't pass a uid for #{e.auth.inspect}"
    Rails.logger.error "Nil user detected: Shibboleth didn't pass a uid for #{e.auth.inspect}"
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    uid
  end

  def active_for_authentication?
    super && !deactivated
  end

  def destroy
    update(deactivated: true) unless deactivated
  end

  # Mailboxer (the notification system) needs the User object to respond to this method
  # in order to send emails
  def mailboxer_email(_object)
    deactivated ? nil : email
  end
end

# Override a Hyrax class that expects to create system users with passwords
module Hyrax::User
  module ClassMethods
    def find_or_create_system_user(user_key)
      u = ::User.find_or_create_by(uid: user_key)
      u.ppid = user_key
      u.display_name = user_key
      u.save
      u
    end
  end
end

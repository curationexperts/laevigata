# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  # Patch engine and gem classes here, so this gets called on reload
  # to re-patch the newly redefined classes
  Hyrax::RedisEventStore.include(LocalOverrides::RedisEventStore)
  Hyrax::LockManager.include(LocalOverrides::LockManager)
end

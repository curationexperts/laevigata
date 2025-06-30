# frozen_string_literal: true

# Override Hyrax::LockManager#initialize
# to avoid deprecated calls to `Redis.current`

module LocalOverrides
  module LockManager
    def self.included(k)
      k.class_eval do
        def initialize(time_to_live, retry_count, retry_delay)
          @ttl = time_to_live
          @client = Redlock::Client.new([Hyrax::RedisEventStore.instance], retry_count: retry_count, retry_delay: retry_delay)
        end
      end
    end
  end
end

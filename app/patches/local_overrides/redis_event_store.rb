# frozen_string_literal: true

# Override Hyrax::RedisEventStore#instance
# to avoid deprecated calls to `Redis.current`

module LocalOverrides
  module RedisEventStore
    def self.included(k)
      k.class_eval do
        def self.instance
          @instance ||= Redis::Namespace.new(namespace, redis: Redis.new(REDIS_CONFIG))
        end
      end
    end
  end
end

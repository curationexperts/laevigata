require 'redis'
config = YAML.safe_load(ERB.new(IO.read(Rails.root.join('config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
Redis.silence_deprecations
Redis.current = Redis.new(config.merge(thread_safe: true))

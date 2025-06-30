# frozen_string_literal: true

require 'redis'

REDIS_CONFIG = YAML.safe_load(ERB.new(IO.read(Rails.root.join('config', 'redis.yml'))).result)[Rails.env].with_indifferent_access

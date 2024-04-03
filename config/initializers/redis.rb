# frozen_string_literal: true

# config/initializers/redis.rb

require 'redis'

REDIS = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/1')

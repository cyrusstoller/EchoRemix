require "redis"

REDIS = Redis.new(Rails.application.config_for("cable"))
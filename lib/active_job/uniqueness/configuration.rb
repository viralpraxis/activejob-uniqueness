# frozen_string_literal: true

require 'openssl'

module ActiveJob
  module Uniqueness
    # Use config/initializer/activejob_uniqueness.rb to configure ActiveJob::Uniqueness
    #
    # ActiveJob::Uniqueness.configure do |c|
    #   c.lock_ttl = 3.hours
    # end
    #
    class Configuration
      module Validations
        def on_conflict=(action)
          validate_on_conflict_action!(action)

          super
        end

        def validate_on_conflict_action!(action)
          return if action.nil? || %i[log raise].include?(action) || action.respond_to?(:call)

          raise ActiveJob::Uniqueness::InvalidOnConflictAction, "Unexpected '#{action}' action on conflict"
        end

        def on_redis_connection_error=(action)
          validate_on_redis_connection_error!(action)

          super
        end

        def validate_on_redis_connection_error!(action)
          return if action.nil? || action == :raise || action.respond_to?(:call)

          raise ActiveJob::Uniqueness::InvalidOnConflictAction,
                "Unexpected '#{action}' action on_redis_connection_error"
        end
      end

      class_attribute :lock_ttl, default: 86_400
      class_attribute :lock_prefix, default: 'activejob_uniqueness'
      class_attribute :on_conflict, default: :raise
      class_attribute :on_redis_connection_error, default: :raise
      class_attribute :redlock_servers, default: [ENV.fetch('REDIS_URL', 'redis://localhost:6379')]
      class_attribute :redlock_options, default: { retry_count: 0 }
      class_attribute :lock_strategies, default: {}

      class_attribute :digest_method, default: OpenSSL::Digest::MD5

      prepend Validations
    end
  end
end

require 'envied/version'
require 'envied/cli'
require 'envied/coercer'
require 'envied/variable'
require 'envied/configuration'
require 'virtus'

class ENVied
  class << self
    attr_reader :env, :config
  end

  def self.require(*groups)
    @config ||= Configuration.load
    @env ||= EnvProxy.new(@config, groups: required_groups(*groups))

    report_missing
    report_uncoercible
  end

  def self.report_missing
    names = env.missing_variables.map(&:name)
    raise "Missing: #{names * ','}" if names.any?
  end

  def self.report_uncoercible
    names = env.uncoercible_variables.map(&:name)
    raise "Uncoercible: #{names * ','}" if names.any?
  end

  def self.required_groups(*groups)
    result = groups.compact
    result.any? ? result.map(&:to_sym) : [:default]
  end

  def self.method_missing(method, *args, &block)
    respond_to_missing?(method) ? (env && env[method.to_s]) : super
  end

  def self.respond_to_missing?(method, include_private = false)
    (env && env.has_key?(method)) || super
  end
end

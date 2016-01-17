require 'ostruct'
module Lakitu::Options
  DEFAULTS = {
    refresh_interval_minutes: 10
  }

  PROFILE_DEFAULTS = {
    ignore: false
  }
  @@options = OpenStruct.new DEFAULTS

  def self.options
    @@options
  end

  def self.options= arg
    @@options = OpenStruct.new arg.merge(DEFAULTS)
  end

  def self.create_provider_defaults
    options[:providers] ||= {}
    Lakitu::Provider.providers.each do |provider_class|
      result = provider_class.new.profiles.inject({}) do |memo, profile|
        memo[profile.to_sym] = PROFILE_DEFAULTS.dup
        memo
      end
      provider_key = provider_class.name.downcase.split('::').last.to_sym
      options[:providers][provider_key] = result
    end
  end
end
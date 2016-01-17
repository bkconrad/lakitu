require 'ostruct'
module Lakitu::Options
  DEFAULTS = {
    refresh_interval_minutes: 10
  }

  PROFILE_DEFAULTS = {
    ignore: false
  }

  @@options = nil

  def self.options
    unless @@options
      @@options = OpenStruct.new(DEFAULTS.merge config_options)
    end
    @@options
  end

  def self.options= arg
    @@options = arg ? OpenStruct.new(arg) : arg
  end

  def self.merge arg
    @@options = OpenStruct.new(options.to_h.merge arg)
  end

  def self.config_options
    return { } unless File.exist?(Lakitu::OPTIONS_FILE_PATH)
    Lakitu.deep_symbolize_keys(::YAML::load(File.read(Lakitu::OPTIONS_FILE_PATH)) || {})
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
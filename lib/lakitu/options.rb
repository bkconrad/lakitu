require 'ostruct'
module Lakitu::Options
  DEFAULTS = {
    refresh_interval_minutes: 10
  }

  PROFILE_DEFAULTS = {
    ignore: false,
    format: "%{profile}-%{name}-%{id}"
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
    deep_symbolize_keys(::YAML::load(File.read(Lakitu::OPTIONS_FILE_PATH)) || {})
  end

  def self.default_config
    create_provider_defaults
    YAML.dump(deep_stringify_keys(options.to_h))
  end

  private
  def self.deep_stringify_keys object
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[key.to_s] = deep_stringify_keys(value)
      end
    when Array
      object.map {|e| deep_stringify_keys(e) }
    else
      object
    end
  end

  def self.deep_symbolize_keys object
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[key.to_sym] = deep_symbolize_keys(value)
      end
    when Array
      object.map {|e| deep_symbolize_keys(e) }
    else
      object
    end
  end

  def self.create_provider_defaults
    options[:providers] ||= {}
    Lakitu::Provider.providers.each do |provider_class|
      provider_key = provider_class.name.downcase.split('::').last.to_sym
      next if options[:providers][provider_key]
      result = provider_class.new.profiles.inject({}) do |memo, profile|
        memo[profile.to_sym] = PROFILE_DEFAULTS.dup
        memo
      end
      options[:providers][provider_key] = result
    end
  end
end
require 'yaml'
module Lakitu::Configurer
  def self.configure
    self.find_or_create_config
    self.edit
  end

  def self.find_or_create_config
    unless Lakitu::FileOperator.lakitu_config_exists?
      Lakitu::FileOperator.write_lakitu_config default_config
    end

    Lakitu::FileOperator.read_lakitu_config
  end

  def self.edit
    system Lakitu::EDIT_FILE_COMMAND
  end

  def self.default_config
    Lakitu::Options.create_provider_defaults
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

  def self.options
    Lakitu::Options::options
  end
end
require 'yaml'
module Lakitu::Configurer
  def self.find_or_create_config
    unless Lakitu::FileOperator.lakitu_config_exists?
      Lakitu.logger.debug "Creating new config file"
      Lakitu::FileOperator.write_lakitu_config Lakitu::Options.default_config
    end

    Lakitu::FileOperator.read_lakitu_config
  end

  def self.edit
    system Lakitu::EDIT_FILE_COMMAND
  end

  def self.edit_local
    system Lakitu::EDIT_LOCAL_CONFIG_COMMAND
  end
end
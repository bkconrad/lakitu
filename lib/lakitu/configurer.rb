require 'yaml'
module Lakitu::Configurer
  def self.configure
    self.find_or_create_config
    self.edit
  end

  def self.find_or_create_config
    unless Lakitu::FileOperator.lakitu_config_exists?
      Lakitu::FileOperator.write_lakitu_config Lakitu::Options.default_config
    end

    Lakitu::FileOperator.read_lakitu_config
  end

  def self.edit
    system Lakitu::EDIT_FILE_COMMAND
  end


  def self.options
    Lakitu::Options::options
  end
end
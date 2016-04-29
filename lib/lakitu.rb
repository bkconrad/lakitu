$LOAD_PATH << File.dirname(File.expand_path(__FILE__))
require "logger"
require "yaml"
require "thor"

class Lakitu < Thor
  LOCAL_SSHCONFIG_PATH = File.expand_path '~/.ssh/local.sshconfig'
  MANAGED_SSH_CONFIG_TOKEN = "# Managed by Lakitu"
  OPTIONS_FILE_PATH = File.expand_path "~/.lakitu.yml"
  SSH_PATH = File.expand_path '~/.ssh'
  SSHCONFIG_PATH = File.expand_path '~/.ssh/config'
  EDIT_FILE_COMMAND = "#{ENV['EDITOR'] || 'nano'} #{OPTIONS_FILE_PATH}"
  DEFAULT_FORMAT = "%{profile}-%{name}-%{id}"
  EDIT_LOCAL_CONFIG_COMMAND = "$EDITOR #{LOCAL_SSHCONFIG_PATH}"

  class_options %w( force -f ) => :boolean
  class_options %w( verbose -v ) => :boolean

  desc "generate [options]", "Generate the ssh config"
  def generate
    Lakitu::Options.merge options
    Lakitu::FileOperator.backup_ssh_config!
    Lakitu::FileOperator.write_ssh_config! Lakitu::Generator.generate if Lakitu::FileOperator::should_overwrite
  end

  desc "configure [options]", "Open Lakitu's config file in the system editor"
  def configure
    Lakitu::Options.merge options
    Lakitu::Configurer.find_or_create_config
    Lakitu::Configurer.edit
  end

  desc "edit", "edit #{Lakitu::LOCAL_SSHCONFIG_PATH} and generate config after"
  def edit
    Lakitu::Options.options[:force] = true
    invoke :generate if Lakitu::Configurer.edit_local
  end

  @@logger = nil
  def self.logger
    unless @@logger
      @@logger = ::Logger.new STDOUT
      logger.level = Lakitu::Options.options.verbose ? ::Logger::DEBUG : ::Logger::INFO
      logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity}: #{msg}\n"
      end
    end
    @@logger
  end

  def self.logger= arg
    @@logger = arg
  end
end

require "lakitu/version"
require "lakitu/configurer"
require "lakitu/file_operator"
require "lakitu/generator"
require "lakitu/options"
require "lakitu/providers/aws"
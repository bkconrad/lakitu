$LOAD_PATH << File.dirname(File.expand_path(__FILE__))
require "yaml"
require "thor"
require "lakitu/version"
require "lakitu/configurer"
require "lakitu/file_operator"
require "lakitu/generator"
require "lakitu/options"
require "lakitu/providers/aws"

class Lakitu < Thor
  LOCAL_SSHCONFIG_PATH = File.expand_path '~/.ssh/local.sshconfig'
  MANAGED_SSH_CONFIG_TOKEN = "# Managed by Lakitu"
  OPTIONS_FILE_PATH = File.expand_path "~/.lakitu.yml"
  SSH_PATH = File.expand_path '~/.ssh'
  SSHCONFIG_PATH = File.expand_path '~/.ssh/config'
  EDIT_FILE_COMMAND = "$EDITOR #{OPTIONS_FILE_PATH}"

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
    Lakitu::Configurer.configure
  end
end

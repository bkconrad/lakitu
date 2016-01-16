$LOAD_PATH << File.dirname(File.expand_path(__FILE__))
require "yaml"
require "thor"
require "lakitu/version"
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

  method_options %w( force -f ) => :boolean
  method_options %w( verbose -v ) => :boolean
  desc "generate [options]", "Generate the ssh config"
  def generate
    Lakitu::Options.options = options
    Lakitu::FileOperator.backup_ssh_config!
    Lakitu::FileOperator.write_config! Lakitu::Generator.generate
  end

  private

  def options
    original_options = super
    return original_options unless File.exist?(OPTIONS_FILE_PATH)
    defaults = ::YAML::load(File.read(OPTIONS_FILE_PATH)) || {}
    @loaded_options = Thor::CoreExt::HashWithIndifferentAccess.new(defaults.merge(original_options))
  end
end

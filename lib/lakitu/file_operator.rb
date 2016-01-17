require 'erb'
require 'ostruct'
module Lakitu::FileOperator
  def self.key_path key_name
    expected_key_path = File.join Lakitu::SSH_PATH, "#{key_name}.pem"
    return nil unless File.exist? expected_key_path
    expected_key_path
  end

  def self.write_ssh_config! content
    raise RuntimeError.new("Won't overwrite unmanaged ssh config") unless ssh_config_is_managed? or !File.exist?(Lakitu::SSHCONFIG_PATH)
    File.write Lakitu::SSHCONFIG_PATH, content
  end

  def self.local_ssh_config
    return File.read(Lakitu::LOCAL_SSHCONFIG_PATH) if File.exist?(Lakitu::LOCAL_SSHCONFIG_PATH)
    return ""
  end

  def self.should_overwrite
    return true unless ssh_config_is_managed?
    ssh_config_is_stale?
  end

  def self.backup_ssh_config!
    return unless File.exist? Lakitu::SSHCONFIG_PATH
    unless ssh_config_is_managed?
      Lakitu.logger.debug "SSH config is unmanaged"
      if File.exist? Lakitu::LOCAL_SSHCONFIG_PATH
        Lakitu.logger.fatal "Can't back up unmanaged ssh config: #{Lakitu::LOCAL_SSHCONFIG_PATH} already exists."
        exit 1
        return
      end

      Lakitu.logger.debug "Moving #{Lakitu::SSHCONFIG_PATH} to #{Lakitu::LOCAL_SSHCONFIG_PATH}"
      FileUtils.mv Lakitu::SSHCONFIG_PATH, Lakitu::LOCAL_SSHCONFIG_PATH
    end
  end

  def self.ssh_config_is_managed?
    return false unless File.exist? Lakitu::SSHCONFIG_PATH
    File.read(Lakitu::SSHCONFIG_PATH).include? Lakitu::MANAGED_SSH_CONFIG_TOKEN
  end

  def self.ssh_config_is_stale?
    really_stale = (Time.now - File.mtime(Lakitu::SSHCONFIG_PATH)) > options.refresh_interval_minutes * 60
    return !!(really_stale or options.force)
  end

  def self.lakitu_config_exists?
    File.exist? Lakitu::OPTIONS_FILE_PATH
  end

  def self.read_lakitu_config
    File.read Lakitu::OPTIONS_FILE_PATH
  end

  def self.write_lakitu_config content
    File.write Lakitu::OPTIONS_FILE_PATH, content
  end

  def self.options
    Lakitu::Options.options
  end
end
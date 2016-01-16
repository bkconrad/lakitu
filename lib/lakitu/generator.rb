require 'erb'
require 'ostruct'
class Lakitu::Generator
  MANAGED_SSH_CONFIG_TOKEN = "# Managed by Lakitu"
  SSH_PATH = File.expand_path '~/.ssh'
  SSHCONFIG_PATH = File.expand_path '~/.ssh/config'
  LOCAL_SSHCONFIG_PATH = File.expand_path '~/.ssh/local.sshconfig'
  CLAUSE_TEMPLATE=<<-EOF
Host <%= host %><% if keyfile %>
  IdentityFile <%= keyfile %>
  <% end %>
  HostName <%= public_ip %>
  EOF

  def generate
    ([ MANAGED_SSH_CONFIG_TOKEN, local_ssh_config ] + instances.map do |instance|
      instance[:host] = "%{profile}-%{name}-%{id}" % instance
      expected_key_path = File.join SSH_PATH, "#{instance[:key]}.pem"
      instance[:keyfile] = expected_key_path if File.exist? expected_key_path
      ERB.new(CLAUSE_TEMPLATE).result(OpenStruct.new(instance).instance_eval { binding })
    end).join("\n")
  end

  def generate!
    backup_ssh_config!
    File.write SSHCONFIG_PATH, generate
  end

  def instances
    Lakitu::Provider.providers.map do |provider_class|
      get_instances(provider_class.new)
    end.flatten
  end

  def should_overwrite
    return true unless ssh_config_is_managed?
    ssh_config_is_stale?
  end

  private

  def backup_ssh_config!
    unless ssh_config_is_managed?
      puts "ssh config is unmanaged"
      if File.exist? LOCAL_SSHCONFIG_PATH
        puts "Can't back up unmanaged ssh config: #{LOCAL_SSHCONFIG_PATH} already exists."
        exit 1
        return
      end

      puts "moving #{SSHCONFIG_PATH} to #{LOCAL_SSHCONFIG_PATH}"
      FileUtils.mv SSHCONFIG_PATH, LOCAL_SSHCONFIG_PATH
    end
  end

  def get_instances provider
    provider.profiles.map do |profile|
      provider.regions.map do |region|
        provider.instances(profile, region)
      end
    end.flatten
  end

  def local_ssh_config
    return File.read(LOCAL_SSHCONFIG_PATH) if File.exist?(LOCAL_SSHCONFIG_PATH)
    return ""
  end

  def ssh_config_is_managed?
    return false unless File.exist? SSHCONFIG_PATH
    File.read(SSHCONFIG_PATH).include? MANAGED_SSH_CONFIG_TOKEN
  end

  def ssh_config_is_stale?
    really_stale = (Time.now - File.mtime(SSHCONFIG_PATH)) > options.wait_time * 60
    return !!(really_stale or options.force)
  end

  def options
    Lakitu::Options::options
  end
end
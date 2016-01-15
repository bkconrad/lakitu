require 'erb'
require 'ostruct'
class Lakitu::Generator
  LOCAL_SSHCONFIG_PATH = File.expand_path '~/.ssh/local.sshconfig'
  CLAUSE_TEMPLATE=<<-EOF
Host <%= host %><% if keyfile %>
  IdentityFile <%= keyfile %>
  <% end %>
  HostName <%= public_ip %>
  EOF

  def generate
    ([ local_ssh_config ] + instances.map do |instance|
      instance[:host] = "%{profile}-%{name}-%{id}" % instance
      ERB.new(CLAUSE_TEMPLATE).result(OpenStruct.new(instance).instance_eval { binding })
    end).join("\n")
  end

  def generate!
    puts generate
  end

  def instances
    Lakitu::Provider.providers.map do |provider_class|
      get_instances(provider_class.new)
    end.flatten
  end

  private

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
end
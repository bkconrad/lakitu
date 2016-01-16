require 'erb'
require 'ostruct'
module Lakitu::Generator
  CLAUSE_TEMPLATE=<<-EOF
Host <%= host %><% if keyfile %>
  IdentityFile <%= keyfile %>
  <% end %>
  HostName <%= public_ip %>
  EOF

  def self.generate
    ([ Lakitu::MANAGED_SSH_CONFIG_TOKEN, Lakitu::FileOperator::local_ssh_config ] + instances.map do |instance|
      instance[:host] = "%{profile}-%{name}-%{id}" % instance
      key_path = Lakitu::FileOperator.key_path instance[:key]
      instance[:keyfile] = key_path if key_path
      ERB.new(CLAUSE_TEMPLATE).result(OpenStruct.new(instance).instance_eval { binding })
    end).join("\n")
  end

  def self.instances
    Lakitu::Provider.providers.map do |provider_class|
      get_instances(provider_class.new)
    end.flatten
  end

  private

  def self.get_instances provider
    provider.profiles.map do |profile|
      provider.regions.map do |region|
        provider.instances(profile, region)
      end
    end.flatten
  end

  def self.options
    Lakitu::Options::options
  end
end
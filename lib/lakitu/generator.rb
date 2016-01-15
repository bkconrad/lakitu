require 'erb'
require 'ostruct'
class Lakitu::Generator
  CLAUSE_TEMPLATE=<<-EOF
Host <%= host %><% if keyfile %>
  IdentityFile <%= keyfile %>
  <% end %>
  HostName <%= public_ip %>
  EOF

  def generate
    instances.map do |instance|
      instance[:host] = "%{profile}-%{name}-%{id}" % instance
      ERB.new(CLAUSE_TEMPLATE).result(OpenStruct.new(instance).instance_eval { binding })
    end.join("\n")
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
end
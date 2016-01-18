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
      instance[:host] = format_for(instance[:provider], instance[:profile]) % instance
      key_path = Lakitu::FileOperator.key_path instance[:key]
      instance[:keyfile] = key_path if key_path
      ERB.new(CLAUSE_TEMPLATE).result(OpenStruct.new(instance).instance_eval { binding })
    end).join("\n")
  end

  def self.instances
    result = Lakitu::Provider.providers.map do |provider_class|
      Lakitu.logger.debug "Getting instances for #{provider_class.name}"
      get_instances(provider_class.new)
    end.flatten
    Lakitu.logger.info "Found #{result.length} instances"
    result
  end

  private

  def self.get_instances provider
    provider.profiles.map do |profile|
      Lakitu.logger.debug "Profile: #{profile}"
      provider.regions.map do |region|
        Lakitu.logger.debug "  Region: #{region}"
        result = provider.instances(profile, region)
        Lakitu.logger.debug "    Found #{(result.length rescue 0)} instances"
        result
      end
    end.flatten
  end

  def self.format_for provider, profile
    (options[:providers][provider.to_sym][profile.to_sym][:format] rescue nil) || Lakitu::DEFAULT_FORMAT
  end

  def self.options
    Lakitu::Options::options
  end
end
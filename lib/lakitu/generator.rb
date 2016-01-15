class Lakitu::Generator
  def instances
    Lakitu::Provider.providers.map do |provider_class|
      get_instances(provider_class.new)
    end.flatten
  end

  def get_instances provider
    provider.profiles.map do |profile|
      provider.regions.map do |region|
        provider.instances(profile, region)
      end
    end.flatten
  end
end
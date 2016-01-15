class Lakitu::Provider
  @@providers = []
  def initialize
    Lakitu::Provider.add_provider self
  end

  def self.providers
    @@providers
  end

  def self.add_provider provider
    @@providers.push provider
  end
end
class Lakitu::Provider
  @@providers = []

  def self.providers
    @@providers
  end

  def self.inherited provider
    @@providers.push provider
  end
end
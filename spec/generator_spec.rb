describe Lakitu::Generator do
  subject { described_class.new }
  before :each do
    stub_aws
    mock_config
  end

  it "invokes all providers, for all regions, over all profiles" do
    expect(Lakitu::Provider.providers.length).to be > 0
    Lakitu::Provider.providers.each do |provider_class|
      provider = provider_class.new
      provider.profiles.each do |profile|
        provider.regions.each do |region|
          expect_any_instance_of(provider_class).to receive(:instances).with(profile, region).exactly(:once)
        end
      end
    end

    subject.instances
  end

  it "merges instance lists from the providers" do
    WRANGLED_INSTANCE_DATA_COMPLETE.each do |x|
      expect(subject.instances).to include x
    end
  end

  it "generates ssh config content from templates" do
    expect(subject.generate).to include SSH_CONFIG_RESULT
  end

  it "reads ~/.ssh/*.sshconfig files"
  it "writes the result to ~/.ssh/config"
end
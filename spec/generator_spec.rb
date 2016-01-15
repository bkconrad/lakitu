describe Lakitu::Generator do
  subject { described_class.new }
  before :each do
    stub_aws
    mock_config
  end

  it "invokes all providers" do
    expect(Lakitu::Provider.providers.length).to be > 0
    Lakitu::Provider.providers.each do |provider|
      expect_any_instance_of(provider).to receive(:instances).at_least(:once)
    end

    subject.instances
  end

  it "merges instance lists from the providers"
  it "generates ssh config content from templates"
  it "reads ~/.ssh/*.sshconfig files"
  it "writes the result to ~/.ssh/config"
end
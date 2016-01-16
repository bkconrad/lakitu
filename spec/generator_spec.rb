describe Lakitu::Generator do
  subject { described_class.new }
  before :each do
    stub_aws
    mock_config
    allow(File).to receive(:write).and_return(true)
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
    mock_no_local_sshconfig
    mock_no_ssh_keys
    expect(subject.generate).to include SSH_CONFIG_RESULT
  end

  it "reads ~/.ssh/*.sshconfig files" do
    mock_no_ssh_keys
    mock_local_sshconfig
    expect(subject.generate).to include LOCAL_SSHCONFIG
  end

  it "moves unmanaged ssh configs to local.sshconfig" do
    mock_no_ssh_keys
    mock_unmanaged_sshconfig
    mock_no_local_sshconfig
    expect(FileUtils).to receive(:mv).with(Lakitu::Generator::SSHCONFIG_PATH, Lakitu::Generator::LOCAL_SSHCONFIG_PATH)
    subject.generate!
  end

  it "does not move managed ssh configs to local.sshconfig" do
    mock_no_ssh_keys
    mock_managed_sshconfig
    mock_no_local_sshconfig
    expect(FileUtils).not_to receive(:mv).with(Lakitu::Generator::SSHCONFIG_PATH, Lakitu::Generator::LOCAL_SSHCONFIG_PATH)
    subject.generate!
  end

  it "exits when ssh config is unmanaged and local.sshconfig exists" do
    mock_no_ssh_keys
    mock_unmanaged_sshconfig
    mock_local_sshconfig
    expect(FileUtils).not_to receive(:mv).with(Lakitu::Generator::SSHCONFIG_PATH, Lakitu::Generator::LOCAL_SSHCONFIG_PATH)
    expect(subject).to receive(:exit).with(1)
    subject.generate!
  end

  it "writes the result to ~/.ssh/config" do
    mock_no_ssh_keys
    mock_managed_sshconfig
    mock_local_sshconfig

    expect(FileUtils).not_to receive(:mv).with(Lakitu::Generator::SSHCONFIG_PATH, Lakitu::Generator::LOCAL_SSHCONFIG_PATH)
    expect(File).to receive(:write).with(Lakitu::Generator::SSHCONFIG_PATH, subject.generate)
    subject.generate!
  end

  it "looks up keys in ~/.ssh/" do
    mock_ssh_keys
    mock_no_local_sshconfig
    expect(subject.generate).to include "IdentityFile #{File.expand_path("~/.ssh/testkey.pem")}"
  end
end
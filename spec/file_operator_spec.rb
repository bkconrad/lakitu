describe Lakitu::FileOperator do
  subject { described_class }
  before :each do
    allow(File).to receive(:write).and_return(true)
  end

  it "moves unmanaged ssh configs to local.sshconfig" do
    mock_no_ssh_keys
    mock_unmanaged_sshconfig
    mock_no_local_sshconfig
    expect(FileUtils).to receive(:mv).with(Lakitu::SSHCONFIG_PATH, Lakitu::LOCAL_SSHCONFIG_PATH)
    subject.backup_ssh_config!
  end

  context "when config is managed" do
    before :each do mock_managed_sshconfig end

    context "and ssh config is fresh" do
      before :each do mock_fresh_sshconfig end
      it "will not overwrite the config" do expect(subject.should_overwrite).to be false end

      context "and force is true" do
        before :each do subject.send(:options)[:force] = true end
        it "will overwrite the config" do expect(subject.should_overwrite).to be true end
      end
    end

    context "and ssh config is stale" do
      before :each do mock_stale_sshconfig end
      it "will overwrite the config" do expect(subject.should_overwrite).to be true end
    end

    it "does not move ssh configs to local.sshconfig" do
      expect(FileUtils).not_to receive(:mv).with(Lakitu::SSHCONFIG_PATH, Lakitu::LOCAL_SSHCONFIG_PATH)
      subject.backup_ssh_config!
    end

    it "writes the result to ~/.ssh/config" do
      expect(FileUtils).not_to receive(:mv).with(Lakitu::SSHCONFIG_PATH, Lakitu::LOCAL_SSHCONFIG_PATH)
      expect(File).to receive(:write).with(Lakitu::SSHCONFIG_PATH, "test")
      subject.write_config! "test"
    end
  end

  context "when config is unmanaged" do
    before :each do mock_unmanaged_sshconfig end
    it "will overwrite the config" do expect(subject.should_overwrite).to be true end

    it "exits when local.sshconfig exists" do
      mock_no_ssh_keys
      mock_local_sshconfig_exists
      expect(FileUtils).not_to receive(:mv).with(Lakitu::SSHCONFIG_PATH, Lakitu::LOCAL_SSHCONFIG_PATH)
      expect(subject).to receive(:exit).with(1)
      subject.backup_ssh_config!
    end
  end
end
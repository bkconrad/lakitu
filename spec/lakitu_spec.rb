describe Lakitu do
  subject { described_class.new }
  it "delegates generate!" do
    expect(Lakitu::FileOperator).to receive(:backup_ssh_config!).and_return(nil)
    expect(Lakitu::Generator).to receive(:generate).and_return("test")
    expect(Lakitu::FileOperator).to receive(:write_ssh_config!).and_return(nil)
    expect(Lakitu::FileOperator).to receive(:should_overwrite).and_return(true)
    subject.generate
  end

  it "delegates configure" do
    expect(Lakitu::Configurer).to receive(:configure).and_return("test")
    subject.configure
  end

  it "delegates edit" do
    expect(Lakitu::Configurer).to receive(:edit_local).and_return(true)
    expect(subject).to receive(:invoke).with(:generate).and_return(true)
    subject.edit
  end
end
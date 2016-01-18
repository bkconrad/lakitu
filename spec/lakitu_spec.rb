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
    expect(Lakitu::Configurer).to receive(:find_or_create_config).and_return(true)
    expect(Lakitu::Configurer).to receive(:edit).and_return("test")
    subject.configure
  end

  it "delegates edit" do
    expect(Lakitu::Configurer).to receive(:edit_local).and_return(true)
    expect(subject).to receive(:invoke).with(:generate).and_return(true)
    subject.edit
  end

  it "creates a logger" do
    Lakitu.logger = nil
    Lakitu::Options.options.verbose = false
    expect(Lakitu.logger).to be_a(Logger)
  end
end
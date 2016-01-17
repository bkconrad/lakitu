describe Lakitu do
  subject { described_class.new }

  it "looks up options in ~/.lakitu.yml" do
    mock_options
    expect(subject.send(:options)[:verbose]).to be true
  end

  it "delegates generate!" do
    mock_no_options
    expect(Lakitu::FileOperator).to receive(:backup_ssh_config!).and_return(nil)
    expect(Lakitu::Generator).to receive(:generate).and_return("test")
    expect(Lakitu::FileOperator).to receive(:write_ssh_config!).and_return(nil)
    expect(Lakitu::FileOperator).to receive(:should_overwrite).and_return(true)
    subject.generate
  end

  it "delegates configure" do
    mock_no_options
    expect(Lakitu::Configurer).to receive(:configure).and_return("test")
    subject.configure
  end
end
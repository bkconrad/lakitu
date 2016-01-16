describe Lakitu do
  subject { described_class.new }

  it "looks up options in ~/.lakitu.yml" do
    mock_options
    expect(subject.send(:options)[:verbose]).to be true
  end

  it "delegates generate!" do
    expect(Lakitu::FileOperator).to receive(:backup_ssh_config!).and_return(nil)
    expect(Lakitu::Generator).to receive(:generate).and_return("test")
    expect(Lakitu::FileOperator).to receive(:write_config!).and_return(nil)
    subject.generate
  end
end
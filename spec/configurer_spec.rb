describe Lakitu::Configurer do
  subject { described_class }
  before :each do
    mock_config
    allow(File).to receive(:write).and_return(true)
  end

  it "creates config file when it doesn't exist" do
    mock_no_options
    expect(File).to receive(:write).with(Lakitu::OPTIONS_FILE_PATH, Lakitu::Options.default_config).and_return(true)
    expect(File).to receive(:read).with(Lakitu::OPTIONS_FILE_PATH).and_return(Lakitu::Options.default_config)
    expect(subject.find_or_create_config).to eq Lakitu::Options.default_config
  end

  it "uses existing config file when it exists" do
    mock_options
    expect(subject.find_or_create_config).to eq OPTIONS_CONTENT
  end

  it "opens config file in default editor" do
    expect(subject).to receive(:system).with(Lakitu::EDIT_FILE_COMMAND)
    subject.edit
  end

  it "opens local config file in default editor" do
    expect(subject).to receive(:system).with(Lakitu::EDIT_LOCAL_CONFIG_COMMAND)
    subject.edit_local
  end
end
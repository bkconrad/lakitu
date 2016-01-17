describe Lakitu::Configurer do
  subject { described_class }
  before :each do
    mock_config
    allow(File).to receive(:write).and_return(true)
  end

  it "creates config file when it doesn't exist" do
    mock_no_options
    expect(File).to receive(:write).with(Lakitu::OPTIONS_FILE_PATH, Lakitu::Configurer.default_config).and_return(true)
    expect(File).to receive(:read).with(Lakitu::OPTIONS_FILE_PATH).and_return(Lakitu::Configurer.default_config)
    expect(subject.find_or_create_config).to eq Lakitu::Configurer.default_config
  end

  it "uses existing config file when it exists" do
    mock_options
    expect(subject.find_or_create_config).to eq OPTIONS_CONTENT
  end

  it "opens config file in default editor" do
    expect(subject).to receive(:system).with(Lakitu::EDIT_FILE_COMMAND)
    subject.edit
  end

  it "includes providers and profiles in default config" do
    stub_aws
    result = YAML.load(subject.default_config)
    expect(result).to be_a Hash
    expect(result['refresh_interval_minutes']).to eql 10
    expect(result['providers']).to be_a Hash
    expect(result['providers']['aws']['client1']['ignore']).to be false
  end
end
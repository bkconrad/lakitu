describe Lakitu::Options do
  subject { described_class }
  before :each do
    Lakitu::Options.options= nil
    allow(File).to receive(:write).and_return(true)
  end

  it "provides default values for options" do
    mock_no_options
    expect(described_class.options.refresh_interval_minutes).to eq 10
  end

  it "overwrites defaults with config values" do
    mock_options
    expect(described_class.options.refresh_interval_minutes).to eq 5
  end

  it "overwrites config values with command line arguments" do
    mock_options
    Lakitu::Options.merge refresh_interval_minutes: 1
    expect(described_class.options.refresh_interval_minutes).to eq 1
  end

  it "includes providers and profiles in default config" do
    mock_no_options
    mock_config
    stub_aws
    result = YAML.load(subject.default_config)
    expect(result).to be_a Hash
    expect(result['refresh_interval_minutes']).to eql 10
    expect(result['providers']).to be_a Hash
    expect(result['providers']['aws']['client1']['ignore']).to be false
  end
end
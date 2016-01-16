describe Lakitu::Main do
  subject { described_class.new }

  it "looks up options in ~/.lakitu.yml" do
    mock_options
    expect(subject.send(:options)[:verbose]).to be true
  end
end
describe Lakitu::Main do
  subject { described_class.new }

  it "looks up options in ~/.lakitu.yml" do
    mock_options
    expect(subject.send(:options)[:verbose]).to be true
  end

  it "delegates generate!" do
    expect_any_instance_of(Lakitu::Generator).to receive(:generate!).and_return(true)
    subject.generate
  end
end
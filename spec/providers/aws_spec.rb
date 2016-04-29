RSpec.describe Lakitu::Provider::Aws do
  subject { Lakitu::Provider::Aws.new }
  context "with a valid credentials config" do
    before :each do
      mock_config
    end

    it "gets a list of profiles" do
      expect(subject.profiles).to eq ['default', 'client1']
    end
  end

  context "without a valid credentials config" do
    before :each do
      mock_no_config
    end

    it "fails to get a list of profiles" do
      expect(subject.profiles).to eq []
    end
  end

  context "with a given list of instances" do
    before do
      stub_aws
    end

    it "gets a list of instances for a given profile" do
      expect(subject.instances('default', 'us-east-1')).to eq(WRANGLED_INSTANCE_DATA_COMPLETE)
    end
  end
end
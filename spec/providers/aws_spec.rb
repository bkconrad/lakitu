require 'json'
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

  context "with a given list of instances" do
    before do
      stub_aws
    end

    it "gets a list of instances for a given profile" do
      expect(subject.instances('epoxy').to_json).to eq(WRANGLED_INSTANCE_DATA.to_json)
    end
  end
end
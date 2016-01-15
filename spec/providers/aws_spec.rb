require 'providers/aws'
RSpec.describe Lakitu::Provider::Aws do
  subject { Lakitu::Provider::Aws.new }
  it "gets a list of profiles"
  it "gets a list of instances for each profile"
end
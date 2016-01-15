AWS_CREDENTIALS_CONTENT=<<EOF
[default]
aws_access_key_id = ACCESSKEY
aws_secret_access_key = SECRETKEY
region = us-west-2

[client1]
aws_access_key_id = ACCESSKEY
aws_secret_access_key = SECRETKEY
region = us-east-1
EOF

require 'json'
require 'providers/aws'
RSpec.describe Lakitu::Provider::Aws do
  subject { Lakitu::Provider::Aws.new }
  context "with a valid credentials config" do
    before :each do
      expect(File).to receive(:read).with(File.expand_path('~/.aws/credentials')).and_return AWS_CREDENTIALS_CONTENT
    end

    it "gets a list of profiles" do
      expect(subject.profiles).to eq ['default', 'client1']
    end
  end

  context "with a given list of instances" do
    before do
      Aws.config[:ec2] = {
        stub_responses: {
          describe_instances: {
            reservations: [{
              instances: [
                { instance_id: 'i-deadbeef', public_ip_address: '1.2.3.4', key_name: 'testkey', tags: [ { key: 'Name', value: 'test' } ] },
                { instance_id: 'i-beeff00d', public_ip_address: '1.2.3.5', key_name: 'testkey2', tags: [ { key: 'Name', value: 'test2' } ] }
              ]}
            ]
          }
        }
      }
    end

    it "gets a list of instances for a given profile" do
      expected = [
        {
          id: 'i-deadbeef',
          name: 'test',
          key: 'testkey',
          public_ip: '1.2.3.4'
        },
        {
          id: 'i-beeff00d',
          name: 'test2',
          key: 'testkey2',
          public_ip: '1.2.3.5'
        }
      ]
      expect(subject.instances('epoxy').to_json).to eq(expected.to_json)
    end
  end
end
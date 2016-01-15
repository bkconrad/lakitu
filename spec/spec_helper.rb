require './lib/lakitu.rb'

def stub_aws
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

WRANGLED_INSTANCE_DATA_COMPLETE=[
  {
    id: 'i-deadbeef',
    name: 'test',
    key: 'testkey',
    profile: 'default',
    region: 'us-east-1',
    public_ip: '1.2.3.4'
  },
  {
    id: 'i-beeff00d',
    name: 'test2',
    key: 'testkey2',
    profile: 'default',
    region: 'us-east-1',
    public_ip: '1.2.3.5'
  }
]

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
def mock_config
  expect(File).to receive(:read).with(File.expand_path('~/.aws/credentials')).and_return(AWS_CREDENTIALS_CONTENT).at_least(:once)
end

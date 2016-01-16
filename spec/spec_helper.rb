require 'simplecov'
SimpleCov.start

require './lib/lakitu.rb'

def stub_aws
  Aws.config[:ec2] = {
    stub_responses: {
      describe_instances: {
        reservations: [{
          instances: [
            { instance_id: 'i-abcd1234', public_ip_address: '1.2.3.3', key_name: 'testkey', state: { name: 'stopped' }, tags: [ { key: 'Name', value: 'deadman' } ] },
            { instance_id: 'i-deadbeef', public_ip_address: '1.2.3.4', key_name: 'testkey', state: { name: 'running' }, tags: [ { key: 'Name', value: 'test' } ] },
            { instance_id: 'i-beeff00d', public_ip_address: '1.2.3.5', key_name: 'testkey2', state: { name: 'running' }, tags: [ { key: 'Name', value: 'test2' } ] }
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
  allow(File).to receive(:read).with(File.expand_path('~/.aws/credentials')).and_return(AWS_CREDENTIALS_CONTENT).at_least(:once)
end

LOCAL_SSHCONFIG=<<EOF
User myusername
EOF

def mock_local_sshconfig
  expect(File).to receive(:exist?).with(File.expand_path('~/.ssh/local.sshconfig')).and_return(true).at_least(:once)
  expect(File).to receive(:read).with(File.expand_path('~/.ssh/local.sshconfig')).and_return(LOCAL_SSHCONFIG).at_least(:once)
end

def mock_no_local_sshconfig
  expect(File).to receive(:exist?).with(File.expand_path('~/.ssh/local.sshconfig')).and_return(false).at_least(:once)
end

SSH_CONFIG_RESULT=<<EOF
Host default-test-i-deadbeef
  HostName 1.2.3.4
EOF

UNMANAGED_SSH_CONFIG=<<EOF
Host default-test-i-deadbeef
  HostName 1.2.3.4
EOF

def mock_unmanaged_sshconfig
  expect(File).to receive(:exist?).with(File.expand_path('~/.ssh/config')).and_return(true).at_least(:once)
  expect(File).to receive(:read).with(File.expand_path('~/.ssh/config')).and_return(UNMANAGED_SSH_CONFIG).at_least(:once)
end

MANAGED_SSH_CONFIG=<<EOF
# Managed by Lakitu
Host default-test-i-deadbeef
  HostName 1.2.3.4
EOF

def mock_managed_sshconfig
  expect(File).to receive(:exist?).with(File.expand_path('~/.ssh/config')).and_return(true).at_least(:once)
  expect(File).to receive(:read).with(File.expand_path('~/.ssh/config')).and_return(MANAGED_SSH_CONFIG).at_least(:once)
end

def mock_fresh_sshconfig
  expect(File).to receive(:mtime).with(Lakitu::Generator::SSHCONFIG_PATH).and_return(Time.now).at_least(:once)
end

def mock_stale_sshconfig
  expect(File).to receive(:mtime).with(Lakitu::Generator::SSHCONFIG_PATH).and_return(Time.now - 60*60*24).at_least(:once)
end

def mock_ssh_keys
  expect(File).to receive(:exist?).with(File.expand_path('~/.ssh/testkey.pem')).and_return(true).at_least(:once)
  expect(File).to receive(:exist?).with(File.expand_path('~/.ssh/testkey2.pem')).and_return(true).at_least(:once)
end

def mock_no_ssh_keys
  allow(File).to receive(:exist?).with(File.expand_path('~/.ssh/testkey.pem')).and_return(false).at_least(:once)
  allow(File).to receive(:exist?).with(File.expand_path('~/.ssh/testkey2.pem')).and_return(false).at_least(:once)
end

OPTIONS_CONTENT=<<EOF
---
verbose: true
force: true
EOF
def mock_options
  expect(File).to receive(:exist?).with(Lakitu::Main::OPTIONS_FILE_PATH).and_return(true).at_least(:once)
  expect(File).to receive(:read).with(Lakitu::Main::OPTIONS_FILE_PATH).and_return(OPTIONS_CONTENT).at_least(:once)
end

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

require 'providers/aws'
RSpec.describe Lakitu::Provider::Aws do
  subject { Lakitu::Provider::Aws.new }
  it "gets a list of profiles" do
    expect(File).to receive(:read).with(File.expand_path('~/.aws/credentials')).and_return AWS_CREDENTIALS_CONTENT
    expect(subject.profiles).to eq ['default', 'client1']
  end

  it "gets a list of instances for each profile"
end
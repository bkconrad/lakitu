require 'aws-sdk-resources'
require 'iniparse'
require 'lakitu/provider'

class Lakitu::Provider::Aws < Lakitu::Provider
  def profiles
    IniParse.parse(File.read(File.expand_path('~/.aws/credentials'))).to_hash.keys.reject() do |x| x == '__anonymous__' end
  end

  def instances profile, region
    result = ec2(profile, region)
      .instances
      .to_a
      .select { |x| x.state.name == "running" }
      .map { |x| to_hash x }

    result.each do |x|
      x[:profile] = profile
      x[:region] = region
      x[:provider] = 'aws'
    end
  end

  def regions
    [ 'us-east-1', 'us-west-1', 'us-west-2' ]
  end

  private

  def ec2 profile, region
    ::Aws::EC2::Resource.new(region: region, profile: profile)
  end

  def to_hash instance
    {
      id: instance.id,
      name: (instance.tags.select do |x| x.key == 'Name' end.first.value rescue 'blank'),
      key: instance.key_name,
      public_ip: instance.public_ip_address
    }
  end
end
require 'provider'
require 'aws-sdk-resources'
require 'iniparse'

class Lakitu::Provider::Aws < Lakitu::Provider
  def profiles
    IniParse.parse(File.read(File.expand_path('~/.aws/credentials'))).to_hash.keys
  end

  def instances profile
    ec2(profile, 'us-east-1').instances.to_a.map { |x| to_hash x }
  end

  private

  def ec2 profile, region
    ::Aws::EC2::Resource.new(region: region, profile: profile)
  end

  def to_hash instance
    {
      id: instance.id,
      name: instance.tags.select do |x| x.key == 'Name' end.first.value,
      key: instance.key_name,
      public_ip: instance.public_ip_address
    }
  end
end
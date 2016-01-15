require 'provider'
require 'aws-sdk-core'
require 'iniparse'
class Lakitu::Provider::Aws < Lakitu::Provider
  def profiles
    IniParse.parse(File.read(File.expand_path('~/.aws/credentials'))).to_hash.keys
  end
end
$LOAD_PATH << File.dirname(File.expand_path(__FILE__))
require "thor"
require "lakitu/version"
require "lakitu/generator"

class Lakitu::Main < Thor
  desc "generate", "Generate the ssh config"
  def generate
    Lakitu::Generator.new.generate!
  end
end

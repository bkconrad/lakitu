require 'ostruct'
class Lakitu::Options
  DEFAULTS = {
    wait_time: 10
  }
  @@options = OpenStruct.new DEFAULTS

  def self.options
    @@options
  end

  def self.options= arg
    @@options = OpenStruct.new arg
  end
end
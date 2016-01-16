require 'ostruct'
class Lakitu::Options
  @@options = OpenStruct.new

  def self.options
    @@options
  end

  def self.options= arg
    @@options = OpenStruct.new arg
  end
end
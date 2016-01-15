describe Lakitu::Generator do
  it "can be instantiated" do
    described_class.new
  end

  it "invokes all providers"
  it "merges instance lists from the providers"
  it "generates ssh config content from templates"
  it "reads ~/.ssh/*.sshconfig files"
  it "writes the result to ~/.ssh/config"
end
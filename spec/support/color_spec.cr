require "spec"
require "../../src/support/themer"

describe Themer::Color do
  klass = Themer::Color

  it "falls back to lower color depth colors if higher ones aren't set" do
    color = klass.new.set style16: "bold", fg16: "white", bg16: "red"
    color.codes_for(16_000_000).should eq(color.codes_for(16))
  end

  it "does not fall back to lower depth colors if set to 'none'" do
    color = klass.new.set fg: "none", fg16: "red"
    color.codes_for(16_000_000).should eq("")
  end
end

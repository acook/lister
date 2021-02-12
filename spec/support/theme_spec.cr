require "spec"
require "../../src/support/themer"

describe Themer::Theme do
  klass = Themer::Theme

  it "allows default to be nil" do
    klass.new.default.should be_nil
  end

  it "falls back to default if ID not found" do
    theme = klass.new
    theme.default = Themer::Color.new.set style: "italic"
    (default = theme.default).nil? && fail "default should never be nil"

    theme.for("unknown").codes.should eq(default.codes)
  end

  it "has codes for the default entry" do
    theme = klass.new
    theme.default = Themer::Color.new.set style: "italic"
    (default = theme.default).nil? && fail "default should never be nil"

    default.codes.should eq "\e[3m"
  end
end

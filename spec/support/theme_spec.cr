require "./spec_helper"

describe Themer::Theme do
  klass = Themer::Theme

  it "allows default to be nil" do
    theme = klass.new

    theme.default.should be_nil
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

  it "provides handy access to reset codes" do
    theme = klass.new

    theme.reset.codes.should eq "\e[0m"
  end
end

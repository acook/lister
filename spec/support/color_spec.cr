require "./spec_helper"

describe Themer::Color do
  klass = Themer::Color

  it "can test for equality" do
    color1 = klass.new.set style16: "bold", fg16: "white", bg16: "red"
    color2 = klass.new.set style16: "bold", fg16: "white", bg16: "red"

    color1.should eq color2
  end

  it "can test for inequality" do
    color1 = klass.new.set style16: "bold", fg16: "white", bg16: "red"
    color2 = klass.new.set style16: "none", fg16: "white", bg16: "red"

    (color1 == color2).should be_false
  end

  it "falls back to lower color depth colors if higher ones aren't set" do
    color = klass.new.set style16: "bold", fg16: "white", bg16: "red"
    color.codes_for(16_000_000).should eq(color.codes_for(16))
  end

  it "does not fall back to lower depth colors if set to 'none'" do
    color = klass.new.set fg: "none", fg16: "red"
    color.codes_for(16_000_000).should eq("")
  end
end

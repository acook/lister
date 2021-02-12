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

  describe "color codes" do
    it "produces correct normal/reset codes" do
      colorreset = klass.new.set style16: "normal"
      colorreset.codes.should eq "\e[0m"
    end

    it "produces correct 16-color codes" do
      color16 = klass.new.set bg16: "red", style16: "bold", fg16: "white"
      color16.codes.should eq "\e[1;37;41m"
    end

    it "produces correct 256-color codes" do
      color256 = klass.new.set bg256: "33"
      color256.codes.should eq "\e[48;5;33m"
    end

    it "produces correct true-color codes" do
      colortrue = klass.new.set fg: "#1CE1CE", bg: "#5E1F1E"
      colortrue.codes.should eq "\e[38;2;28;225;206m\e[48;2;94;31;30m"
    end
  end
end

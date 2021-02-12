require "./spec_helper"

describe Themer::Color do
  klass = Themer::Color

  describe "#==" do
    it "can test for equality" do
      color1 = klass.new.set style16: "bold", fg16: "white", bg16: "red"
      color2 = klass.new.set style16: "bold", fg16: "white", bg16: "red"

      color1.should eq color2
    end

    it "can test for inequality" do
      color1 = klass.new.set style16: "bold", fg16: "white", bg16: "red"
      color2 = klass.new.set style16: "none", fg16: "white", bg16: "red"

      color1.should_not eq color2
    end
  end

  describe "fallback mechanics" do
    it "falls back to lower color depth colors if higher ones aren't set" do
      color = klass.new.set style16: "bold", fg16: "white", bg16: "red"

      color.codes_for(16_000_000).should eq(color.codes_for(16))
    end

    it "gives precedence to high color depths" do
      color = klass.new.set style: "italic", fg: "#FFFFFF", bg: "#FF0000",
       style16: "bold", fg16: "white", bg16: "red"

       color.codes_for(16_000_000).should_not eq color.codes_for(16)
       color.codes_for(16_000_000).should eq "\e[3m\e[38;2;255;255;255m\e[48;2;255;0;0m"
    end

    it "does not fall back to lower depth colors if set to 'none'" do
      color = klass.new.set fg: "none", bg: "#BADA55", fg16: "red", bg16: "green"
      color.codes_for(16_000_000).should_not eq color.codes_for(16)
      color.codes_for(16_000_000).should eq("\e[48;2;186;218;85m")
    end

    it "combines higher and lower color depth settings" do
      color = klass.new.set bg: "#BADA55", bg256: "54", fg16: "red"
      color.codes_for(16_000_000).should eq("\e[31;48;2;186;218;85m")
    end

    it "selects apporpriate color codes for 255 color depth" do
      color = klass.new.set bg: "#BADA55", bg256: "54", fg16: "red"
      color.codes_for(256).should eq "\e[31;48;5;54m"
    end
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

    it "does split true-color sequences if both fg and bg are given" do
      colortrue = klass.new.set style: "italic", fg: "#1CE1CE", bg: "#5E1F1E"
      colortrue.codes.count('\e').should eq 3
    end

    it "doesn't split true-color if only fg or bg are given" do
      # note that there is only one \e escape sequence here
      colortrue = klass.new.set style: "bold", fg: "#1CE1CE"
      colortrue.codes.count('\e').should eq 1

      colortrue = klass.new.set style: "bold", bg: "#5E1F1E"
      colortrue.codes.count('\e').should eq 1
    end
  end
end

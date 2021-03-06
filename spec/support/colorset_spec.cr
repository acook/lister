require "./spec_helper"

describe Themer::Colorset do
  klass = Themer::Colorset

  describe "#==" do
    it "can test for equality" do
      color1 = klass.new style16: "bold", fg16: "white", bg16: "red"
      color2 = klass.new style16: "bold", fg16: "white", bg16: "red"

      color1.should eq color2
    end

    it "can test for inequality" do
      color1 = klass.new style16: "bold", fg16: "white", bg16: "red"
      color2 = klass.new style16: "skip", fg16: "white", bg16: "red"

      color1.should_not eq color2
    end
  end

  describe "fallback mechanics" do
    it "falls back to lower color depth colors if higher ones aren't set" do
      color = klass.new style16: "bold", fg16: "white", bg16: "red"

      color.codes(16_000_000).should eq(color.codes(16))
    end

    it "gives precedence to high color depths" do
      color = klass.new style: "italic", fg: "#FFFFFF", bg: "#FF0000",
       style16: "bold", fg16: "white", bg16: "red"

       color.codes(16_000_000).should_not eq color.codes(16)
       color.codes(16_000_000).should eq "\e[3m\e[38;2;255;255;255m\e[48;2;255;0;0m"
    end

    it "does not fall back to lower depth colors if set to 'skip'" do
      color = klass.new fg: "skip", bg: "#BADA55", fg16: "red", bg16: "green"
      color.codes(16_000_000).should_not eq color.codes(16)
      color.codes(16_000_000).should eq("\e[48;2;186;218;85m")
    end

    it "combines higher and lower color depth settings" do
      color = klass.new bg: "#BADA55", bg256: "54", fg16: "red"
      color.codes(16_000_000).should eq("\e[31;48;2;186;218;85m")
    end

    it "selects apporpriate color codes for 255 color depth" do
      color = klass.new bg: "#BADA55", bg256: "54", fg16: "red"
      color.codes(256).should eq "\e[31;48;5;54m"
    end
  end

  describe "color codes" do
    it "produces correct normal/reset codes" do
      colorreset = klass.new style16: "normal"
      colorreset.codes(16).should eq "\e[0m"
    end

    it "produces correct 16-color codes" do
      color16 = klass.new bg16: "red", style16: "bold", fg16: "white"
      color16.codes(16).should eq "\e[1;37;41m"
    end

    it "produces correct 256-color codes" do
      color256 = klass.new bg256: "33"
      color256.codes(256).should eq "\e[48;5;33m"
    end

    it "produces correct true-color codes" do
      colortrue = klass.new fg: "#1CE1CE", bg: "#5E1F1E"
      colortrue.codes(16_000_000).should eq "\e[38;2;28;225;206m\e[48;2;94;31;30m"
    end

    it "does split true-color sequences if both fg and bg are given" do
      colortrue = klass.new style: "italic", fg: "#1CE1CE", bg: "#5E1F1E"
      colortrue.codes(16_000_000).to_s.count('\e').should eq 3
    end

    it "doesn't split true-color if only fg is given" do
      colortrue = klass.new style: "bold", fg: "#1CE1CE"
      colortrue.codes(16_000_000).to_s.count('\e').should eq 1
    end

    it "doesn't split true-color if only bg is given" do
      colortrue = klass.new style: "bold", bg: "#5E1F1E"
      colortrue.codes(16_000_000).to_s.count('\e').should eq 1
    end
  end
end

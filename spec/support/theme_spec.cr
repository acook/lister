require "./spec_helper"

describe Themer::Theme do
  klass = Themer::Theme

  it "provides handy access to reset codes" do
    theme = klass.new

    theme.reset.codes.should eq "\e[0m"
  end

  describe "#default" do
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
  end

  describe "#for with arrays" do
    color1 = Themer::Color.new.set style: "italic"
    color2 = Themer::Color.new.set style: "bold"

    theme = klass.new.tap do |theme|
      theme["bar"] = color1
      theme["qux"] = color2
    end

    it "returns the first found of a given list of IDs" do
      theme.for(%w{bar qux}).should eq color1
    end

    it "returns later ids if earlier ones not found" do
      theme.for(%w{foo qux}).should eq color2
    end
  end

  describe "#==" do
    it "recognizes themes with identical settings" do
      theme1 = klass.new.tap do |theme|
        theme["bar"] = Themer::Color.new.set style: "italic"
        theme["qux"] = Themer::Color.new.set style: "bold"
      end

      theme2 = klass.new.tap do |theme|
        theme["bar"] = Themer::Color.new.set style: "italic"
        theme["qux"] = Themer::Color.new.set style: "bold"
      end

      theme1.should eq theme2
    end

    it "detects if defaults are different" do
      theme1 = klass.new
      theme1.default = Themer::Color.new.set style: "italic"
      theme2 = klass.new
      theme2.default = Themer::Color.new.set style: "bold"

      theme1.should_not eq theme2
    end
  end

  describe "loading known theme" do
    fixture_theme_file = "#{__DIR__}/fixtures/theme.yml"

    it "can load valid themes" do
      loaded_theme = klass.load fixture_theme_file

      loaded_theme.should be_a Themer::Theme
    end
  end

  describe "saving and loading internal themes" do
    theme_file = "./tmp/my_testing_theme.theme"

    # this will run for every test, so don't put tests in this context that don't use this file
    around_each do |example|
      File.delete theme_file if File.exists? theme_file
      example.run
    ensure
      File.delete theme_file if File.exists? theme_file
    end

    it "can save themes" do
      theme = klass.new
      theme.default = Themer::Color.new.set style: "italic"
      theme.save theme_file

      File.exists?(theme_file).should be_true
    end

    it "can load themes that it has saved and they will be identical" do
      theme = klass.new
      theme["foo"] = Themer::Color.new.set style: "none", fg16: "black", bg16: "white"
      theme.save theme_file
      loaded_theme = klass.load theme_file

      fail "loaded_them is nil!" if loaded_theme.nil?

      loaded_theme.should eq theme
    end

    it "preserves default fallback color" do
      theme = klass.new
      theme.default = Themer::Color.new.set style: "none", fg16: "black", bg16: "white"
      theme.save theme_file
      loaded_theme = klass.load theme_file

      fail "loaded_them is nil!" if loaded_theme.nil?

      loaded_theme.default.should be_truthy
      loaded_theme.default.should eq theme.default
    end
  end
end

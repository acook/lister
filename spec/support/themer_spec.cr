require "spec"
require "../../src/support/themer"

describe Themer do
  test_theme = Themer.build do
    default style: "italic"
    # style only
    for "reset", style: "normal"
    # 16 colors
    for "err", bg16: "red", style: "bold", fg16: "white"
    # 256 color
    for "thehellofit", bg256: "33"
    # true color
    for "lookatme", fg: "#de1e7e", style: "bold"
    for "foo", fg: "#BADA55"
    for "bar", fg: "#e1e100"
    for "baz", fg: "#c0ffee"
    for "qux", fg: "#1CE1CE"
  end

  it "allows default to be nil" do
    Themer::Theme.new.default.should be_nil
  end

  it "falls back to default if ID not found" do
    default = test_theme.default
    fail "test theme's default was nil when it shouldn't be!" if default.nil?
    test_theme.for("unknown").codes.should eq(default.codes)
  end


  it "does all the things" do
    theme = test_theme

    # @default is allowed to be nil
    default = theme.default
    if default
      default.codes.should eq "\e[3m"
    else
      fail "theme.default was nil"
    end

    theme.reset.codes.should eq theme["reset"].codes

    theme.for("err").codes.should eq "\e[1;37;41m"
    theme["thehellofit"].codes.should eq "\e[48;5;33m"
    theme["lookatme"].codes.should eq "\e[1;38;2;222;30;126m"
    theme.for(%w{bar qux}).codes.should eq "\e[38;2;225;225;0m"

    # test saving and loading
    theme_file = "./tmp/my_testing_theme.theme"
    File.delete theme_file if File.exists? theme_file
    theme.save theme_file
    loaded_theme = Themer::Theme.load theme_file

    loaded_theme.should be_a Themer::Theme

    if loaded_theme.nil?
      raise "loaded_theme is nil!"
    else
      loaded_theme.colormap.map{|_,v| v.codes}.should eq theme.colormap.map{|_,v| v.codes}
    end
  end
end

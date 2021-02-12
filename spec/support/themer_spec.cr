require "./spec_helper"

describe Themer do
  test_theme = Themer.build do
    default style: "italic"
    # style only
    for "reset", style: "normal"
    # 16 colors
    for "err", bg16: "red", style16: "bold", fg16: "white"
    # 256 color
    for "thehellofit", bg256: "33"
    # true color
    for "lookatme", fg: "#de1e7e", style: "bold"
    for "foo", fg: "#BADA55"
    for "bar", fg: "#e1e100"
    for "baz", fg: "#c0ffee"
    for "qux", fg: "#1CE1CE"

    for "hasnoneset", fg: "none", fg16: "red"
  end

  it "does all the things" do
    theme = test_theme

    theme.for("err").codes.should eq "\e[1;37;41m"
    theme["thehellofit"].codes.should eq "\e[48;5;33m"
    theme["lookatme"].codes.should eq "\e[1;38;2;222;30;126m"
    theme.for(%w{bar qux}).codes.should eq "\e[38;2;225;225;0m"
  end
end

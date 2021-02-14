require "./colorset"
require "./builder"
require "./theme"

module Themer
  def self.build
    td = Builder.new
    with td yield td
  end

  alias StrNil = String | Nil

  def self.reset
    internal_theme.reset
  end

  def self.warn(*messages)
    STDERR.print internal_theme.for("warn"), messages.join("\n"), "\e[K", reset, "\n"
  end

  def self.internal_theme
    @@internal_theme
  end

  @@internal_theme : Theme = build do
    default style: "normal"
    for "warn", style16: "bold", fg16: "white", bg16: "red"
  end
end

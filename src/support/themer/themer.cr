require "./color"
require "./builder"
require "./theme"

module Themer
  def self.build
    td = Builder.new
    new_theme = with td yield td
    new_theme
  end

  alias StrNil = String | Nil

  def self.reset
    Color.new.set style: "normal"
  end
end

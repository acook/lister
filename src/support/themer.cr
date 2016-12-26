module Themer
  def self.create
    td = ThemeDefiner.new
    new_theme = with td yield td
    new_theme
  end

  alias COLOR = Symbol | Int32 | String | Nil
  alias STYLE = Symbol | Nil

  class Colors
    property codes : String

    def initialize(bg : COLOR = nil, fg : COLOR = nil, style : STYLE = nil)
      @codes = "\033["

      if style
        @codes += s style
        @codes +=  ";"
      end

      case bg
      when Symbol # 16 colors by name
        @codes += "4#{c bg};"
      when Int # 256 colors by number
        @codes += "48;5;#{bg};"
      when String # true color by hex string
        @codes += "48;2;#{hex bg};"
      end

      case fg
      when Symbol # 16 colors by name
        @codes += "3#{c fg};"
      when Int # 256 colors by number
        @codes += "38;5;#{fg};"
      when String # true color by hex string
        @codes += "38;2;#{hex fg};"
      end

      @codes += "m"
    end

    def to_s(io)
      io.print @codes
    end

    def c(name : Symbol)
      COLORS.index name || raise "color not found: #{name.inspect}"
    end

    def s(name : Symbol)
      STYLES.index name || raise "style not found: #{name.inspect}"
    end

    def hex(hexcode : String)
      raise ArgumentError.new "invalid hex color #{hexcode.inspect}" unless hexcode[0] == '#' && hexcode.size == 7
      r = hexcode[1,2].to_i(16)
      g = hexcode[3,2].to_i(16)
      b = hexcode[5,2].to_i(16)
      "#{r};#{g};#{b}"
    end

    COLORS = %i[black red green yellow blue magenta cyan white extended default]
    STYLES = %i[normal bold faint italic underlined blink blink_fast inverse conceal crossed_out]
  end

  class ThemeDefiner
    property theme = Hash(Symbol, Colors).new

    def for(id : Symbol, bg : COLOR = nil, fg : COLOR = nil, style : STYLE = nil)
      colors = Colors.new bg: bg, fg: fg, style: style
      @theme[id] = colors
      @theme
    end
  end
end

theme = Themer.create do |t|
  t.for :foo, bg: :red
  t.for :bar, fg: "#de1e7e"
end

print theme[:bar], "foooooo", "\033[0m\n"

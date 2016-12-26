require "yaml"

module Themer
  def self.create
    td = ThemeDefiner.new
    new_theme = with td yield td
    new_theme
  end

  alias COLOR = Symbol | Int32 | String | Nil
  alias STYLE = Symbol | Nil

  class Colors
    property codes : String = ""

    def set(bg : COLOR = nil, fg : COLOR = nil, style : STYLE = nil)
      @codes = "\033["

      if style
        @codes += "#{s style};"
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

      self # return self for chaining
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

    def to_yaml(*args)
      codes.to_yaml *args
    end

    COLORS = %i[black red green yellow blue magenta cyan white extended default]
    STYLES = %i[normal bold faint italic underlined blink blink_fast inverse conceal crossed_out]
  end

  class ThemeDefiner
    property theme = Theme.new

    def for(id : String, bg : COLOR = nil, fg : COLOR = nil, style : STYLE = nil)
      colors = Colors.new.set bg: bg, fg: fg, style: style
      @theme[id] = colors
      @theme
    end
  end

  class Theme
    property store = Hash(String, Colors).new
    property reset : Colors = Colors.new.set style: :normal

    def self.load(filename)
      yaml = File.open filename do |file|
        YAML.parse(file)
      end

      data = Hash(String, Colors).new
      yaml.as_h.each do |k,v|
        data[k.to_s] = Colors.new.tap{|c| c.codes = v.to_s }
      end

      self.new.tap{|t| t.store = data }
    end

    def save(filename)
      File.open filename, mode: "w" do |file|
        file.puts YAML.dump(store)
      end
    end

    def [](id : String) : Colors | NoReturn
      store[id] || raise ArgumentError.new("id not found #{id.inspect}")
    end

    def []=(id : String, seq : Colors)
      store[id] = seq || raise ArgumentError.new("key cannot be nil")
    end
  end
end

theme = Themer.create do
  for "reset", style: :normal
  for "err", bg: :red, style: :bold, fg: :white
  for "lookatme", fg: "#de1e7e", style: :bold
  for "foo", fg: "#BADA55"
  for "bar", fg: "#e1e100"
  for "baz", fg: "#c0ffee"
  for "qux", fg: "#1CE1CE"
end

theme.save "mytheme.theme"
theme = Themer::Theme.load "mytheme.theme"

print theme["err"],      "DANGER WILL ROBINSON DANGER DANGER", theme.reset, '\n'
print theme["lookatme"], "EXTERMINATE ANNIHILATE DESTROY",     theme.reset, '\n'
print theme["foo"], "foo ", theme["bar"], "bar ", theme["baz"], "baz ", theme["qux"], "qux "
print theme.reset, '\n'


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
      @codes = "\e["

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

    def parse(code : String) : ThemeColors | NoReturn
      raise ArgumentError.new(
        "doesn't begin with escape sequence, got #{code[0].inspect} instead"
      ) unless code[0] == '\e'
      raise ArgumentError.new(
        "doesn't begin with esc and bracket, got #{code[1].inspect} instead"
      ) unless code[1] == '['

      colors = ThemeColors.new
      pack = ""
      fg_rgb_flag = false
      bg_rgb_flag = false
      fg_256_flag = false
      bg_256_flag = false
      fg = false
      bg = false
      fg_rgb = Array(Int32).new
      bg_rgb = Array(Int32).new
      last = 0

      code.each_char_with_index do |chr, i|
        last = i
        next if i < 2

        if chr.ascii_number?
          pack += chr
        elsif chr == ';'
          num = pack.to_i

          if false # I wonder if this gets optimized out...

          # switches for 256 and true color
          elsif num == 38 # fg extended
            fg = true
          elsif num == 48 # bg extended
            bg = true
          elsif num == 5 && fg # fg 256 color
            fg_256_flag = true
            fg = false
          elsif num == 5 && bg # bg 256 color
            bg_256_flag = true
            bg = false
          elsif num == 2 && fg # fg true color
            fg_rgb_flag = true
            fg = false
          elsif num == 2 && bg # bg true color
            bg_rgb_flag = true
            bg = false

          # 256 and true color codes
          elsif fg_256_flag # store fg 256 color
            colors.fg = num
            fg_256_flag = false
          elsif bg_256_flag # store bg 256 color
            colors.bg = num
            bg_256_flag = false
          elsif fg_rgb_flag # store fg true color
            fg_rgb << num
          elsif bg_rgb_flag # store bg true color
            bg_rgb << num

          # 16 color codes
          elsif num < 38 && num > 29 # it's a fg color
            colors.fg = COLORS[num - 30]
          elsif num < 48 && num > 39 # it's a bg color
            colors.bg = COLORS[num - 40]

          # styles, we have to do these last!
          # there are technically other styles,
          # but we only care about the first 10
          elsif num <= 10 # it's a style! hopefully
            colors.style = STYLES[num]

          # if all else fails... PANIC!
          else
            raise "what is this i dont even PACK=#{pack.inspect}"
          end

          pack = "" # reset the string for the next go-round
        elsif chr == 'm'
          break # end of sequence, probably
        else
          raise ArgumentError.new(
            "unrecognized character, expected digit, semicolon, or 'm' but got #{chr.inspect} instead"
          )
        end

        if fg_rgb.size > 3
          raise "too many fg args"
        elsif bg_rgb.size > 3
          raise "too many bg args"
        end
      end

      if fg_rgb_flag
        fg = "#"
        fg_rgb.each do |n|
          fg += n.to_s(16).rjust(2,'0')
        end
        colors.fg = fg
      end

      if bg_rgb_flag
        bg = "#"
        bg_rgb.each do |n|
          bg += n.to_s(16).rjust(2,'0')
        end
        colors.bg = bg
      end

      raise(
        "more data at the end of the escape sequence " \
        "LAST=#{last} TOTAL=#{code.size} " \
        "DATA=#{code[last, code.size - 1].inspect}"
      ) if (last + 1) < code.size # maybe it wasn't the end of the sequence??

      colors
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

    class ThemeColors
      property bg : COLOR
      property fg : COLOR
      property style : STYLE
    end
  end

  class ThemeDefiner
    property theme = Theme.new

    def for(id : String, bg : COLOR = nil, fg : COLOR = nil, style : STYLE = nil)
      colors = Colors.new.set bg: bg, fg: fg, style: style
      @theme[id] = colors
      @theme
    end

    def default(bg : COLOR = nil, fg : COLOR = nil, style : STYLE = nil)
      @theme.default = Colors.new.set bg: bg, fg: fg, style: style
    end
  end

  class Theme
    property store = Hash(String, Colors).new
    property reset : Colors = Colors.new.set style: :normal
    property default : Colors | Nil

    def self.load(filename)
      yaml = File.open filename do |file|
        YAML.parse(file)
      end

      per_def = nil
      data = Hash(String, Colors).new
      yaml.as_h.each do |k,v|
        colors = Colors.new.tap do |c|
          tc = c.parse v.to_s
          c.set bg: tc.bg, fg: tc.fg, style: tc.style
        end

        if k.to_s == "DEFAULT"
          per_def = colors
        else
          data[k.to_s] = colors
        end
      end

      self.new.tap do |t|
        t.default = per_def if per_def
        t.store = data
      end
    end

    def save(filename)
      per_def = @default
      per = store.dup
      per["DEFAULT"] = per_def if per_def
      File.open filename, mode: "w" do |file|
        file.puts YAML.dump per
      end
    end

    def [](id : String) : Colors | NoReturn
      store[id] || raise ArgumentError.new("id not found #{id.inspect}")
    end

    def []=(id : String, seq : Colors)
      store[id] = seq || raise ArgumentError.new("key cannot be nil")
    end
  end

  def self.reset
    Colors.new.set style: :normal
  end
end

theme = Themer.create do
  default style: :italic
  # style only
  for "reset", style: :normal
  # 16 colors
  for "err", bg: :red, style: :bold, fg: :white
  # 256 color
  for "thehellofit", bg: 33
  # true color
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
print theme["thehellofit"], "ABCDEFGHIJKLMNOP", theme.reset, '\n'
print theme.default, "waddabeat"
print theme.reset, '\n'

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
      skip = false
      fg_rgb = Array(Int32).new
      bg_rgb = Array(Int32).new
      last = -1

      code.each_char_with_index do |chr, i|
        last += 1
        next if i < 2

        if chr.ascii_number?
          pack += chr
        elsif chr == ';'
          num = pack.to_i

          if i == 3 # single digit, probably a style
            colors.style =  STYLES[num]
          elsif num == 38 # fg extended
            skip = :fg
          elsif num == 48 # bg extended
            skip = :bg
          elsif num == 2 && skip # true color
            if skip == :bg
              bg_rgb_flag = true
            elsif skip == :fg
              fg_rgb_flag = true
            else
              raise "what is this i dont even (true) SKIP=#{skip.inspect}"
            end
            skip = false
          elsif num == 5 && skip # 256 color
            if skip == :bg
              bg_256_flag = true
            elsif skip == :fg
              fg_256_flag = true
            else
              raise "what is this i dont even (256) SKIP=#{skip.inspect}"
            end
            skip = false
          elsif fg_rgb_flag # store fg true color
            fg_rgb << num
          elsif bg_rgb_flag # store bg true color
            bg_rgb << num
          elsif fg_256_flag # store fg 256 color
            colors.fg = num
          elsif bg_256_flag # store bg 256 color
            colors.bg = num
          elsif num < 38 && num > 29 # it's a fg color
            colors.fg = COLORS[num - 30]
          elsif num < 48 && num > 39 # it's a bg color
            colors.bg = COLORS[num - 40]
          else
            raise "what is this i dont even (else) CHR=#{chr.inspect}"
          end

          pack = ""
        elsif chr == 'm'
          break # end of sequence
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
      ) if (last + 1) < code.size

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
        #colors = Colors.new.tap{|c| c.codes = v.to_s }
        colors = Colors.new.tap do |c|
          tc = c.parse v.to_s
          c.set bg: tc.bg, fg: tc.fg, style: tc.style
        end
        data[k.to_s] = colors
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
print theme["thehellofit"], "ABCDEFGHIJKLMNOP"
print theme.reset, '\n'

require "yaml"

module Themer
  def self.build
    td = Builder.new
    new_theme = with td yield td
    new_theme
  end

  alias STYLE = String | Nil
  alias CTrue = String | Nil
  alias C16   = String | Nil
  alias C256  = Int8   | Nil

  class Colors
    property codes : String | Nil
    property style : STYLE
    property fg    : CTrue
    property bg    : CTrue
    property fg16  : C16
    property bg16  : C16
    property fg256 : C256
    property bg256 : C256

    def set(
      style : STYLE  = nil,
      fg    : CTrue = nil, bg    : CTrue = nil,
      fg16  : C16   = nil, bg16  : C16   = nil,
      fg256 : C256  = nil, bg256 : C256  = nil
    )

      @style = style if style && !style.empty?
      @fg    = fg    if fg    && !fg.empty?
      @bg    = bg    if bg    && !bg.empty?
      @fg16  = fg16  if fg16  && !fg16.empty?
      @bg16  = bg16  if bg16  && !bg16.empty?
      @fg256 = fg256 if fg256
      @bg256 = bg256 if bg256

      self # return self for chaining
    end

    def codes
      @codes || regen_codes
    end

    def regen_codes(color_depth = 16_000_000)
      new_codes = "\e["

      if tmp_s = style
        new_codes += "#{s tmp_s};"
      end

      if color_depth > 256 && (tmp_fg = fg)
        new_codes += "38;2;#{ct tmp_fg};"
      elsif color_depth > 16 && (tmp_fg256 = fg256)
        new_codes += "38;5;#{tmp_fg256};"
      elsif color_depth > 0 && (tmp_fg16 = fg16)
        new_codes += "3#{c16 tmp_fg16};"
      end

      if (tmp_bg = bg) && color_depth > 256
        new_codes += "48;2;#{ct tmp_bg};"
      elsif (tmp_bg256 = bg256) && color_depth > 16
        new_codes += "48;5;#{tmp_bg256};"
      elsif (tmp_bg16 = bg16) && color_depth > 0
        new_codes += "4#{c16 tmp_bg16};"
      end

      new_codes += "m"
      @codes = new_codes
    end

    def s(name : STYLE)
      STYLES.index name || raise "style not found: #{name.inspect}"
    end

    def c16(name : C16)
      COLORS.index name || 0
    end

    def ct(indicator : CTrue)
      if indicator[0] == '#'
        hex indicator
      else
        hex lookup_rgb indicator
      end
    end

    def lookup_rgb(color_name)
      "#FFFFFF"
    end

    def hex(hexcode : String)
      raise ArgumentError.new "invalid hex color #{hexcode.inspect}" unless hexcode[0] == '#' && hexcode.size == 7
      r = hexcode[1,2].to_i(16)
      g = hexcode[3,2].to_i(16)
      b = hexcode[5,2].to_i(16)
      "#{r};#{g};#{b}"
    end

    def to_s(io)
      io.print codes
    end

    def to_hash
      {
        style: style,
        fg: fg,
        bg: bg,
        fg256: fg256,
        bg256: bg256,
        fg16: fg16,
        bg16: bg16
      }
    end

    def to_yaml(*args)
      to_hash.to_yaml *args
    end

    COLORS = %w[black red green yellow blue magenta cyan white extended default]
    STYLES = %w[normal bold faint italic underlined blink blink_fast inverse conceal crossed_out]
  end

  class Builder
    property theme = Theme.new

    def for( id : String,
      style : STYLE = nil,
      fg    : CTrue = nil, bg    : CTrue = nil,
      fg16  : C16   = nil, bg16  : C16   = nil,
      fg256 : C256  = nil, bg256 : C256  = nil
    )
      colors = Colors.new.set style: style,
        fg:    fg,    bg:    bg,
        fg16:  fg16,  bg16:  bg16,
        fg256: fg256, bg256: bg256
      @theme[id] = colors
      @theme
    end

    def for( id : String,
      style : Symbol = nil,
      fg    : CTrue = nil, bg    : CTrue = nil,
      fg16  : Symbol   = nil, bg16  : Symbol   = nil,
      fg256 : C256  = nil, bg256 : C256  = nil
    )
      colors = Colors.new.set style: (style && style.to_s).as(String | Nil),
        fg:    fg,    bg:    bg,
        fg16:  (fg16 && fg16.to_s).as(String | Nil),  bg16:  (bg16 && bg16.to_s).as(String | Nil),
        fg256: fg256, bg256: bg256
      @theme[id] = colors
      @theme
    end

    def default(
      style : STYLE = nil,
      fg    : CTrue = nil, bg    : CTrue = nil,
      fg16  : C16   = nil, bg16  : C16   = nil,
      fg256 : C256  = nil, bg256 : C256  = nil
    )
      @theme.default = Colors.new.set style: style,
        fg:    fg,    bg:    bg,
        fg16:  fg16,  bg16:  bg16,
        fg256: fg256, bg256: bg256
    end

    def default(
      style : Symbol = nil,
      fg    : CTrue = nil, bg    : CTrue = nil,
      fg16  : Symbol   = nil, bg16  : Symbol   = nil,
      fg256 : C256  = nil, bg256 : C256  = nil
    )
      @theme.default = Colors.new.set style: (style && style.to_s).as(String | Nil),
        fg:    fg,    bg:    bg,
        fg16:  (fg16 && fg16.to_s).as(String | Nil),  bg16:  (bg16 && bg16.to_s).as(String | Nil),
        fg256: fg256, bg256: bg256
    end
  end

  class Theme
    property store = Hash(String, Colors).new
    property reset : Colors = Colors.new.set style: "normal"
    property default : Colors | Nil

    def self.load(filename)
      yaml = Hash(String, Hash(String, CTrue | C256 | C16)).new

      File.open filename do |file|
        yaml = YAML.parse(file)#.as Hash
        #(String, Hash(String, String | Int8 | Nil))
      end

      per_def = nil
      data = Hash(String, Colors).new
      yaml.each do |k,v|
        colors = Colors.new.tap do |c|
          c.set style: v["style"].as(STYLE),
            fg:    v["fg"].to_s,    bg:    v["bg"].to_s,
            fg16:  v["fg16"].to_s,  bg16:  v["bg16"].to_s,
            fg256: v["fg256"].as(Int8), bg256: v["bg256"].as(Int8)
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

    def for(id : String) : Colors | NoReturn
      default = @default  # so the ivar doesn't change during execution
      if default.nil?
        store[id] || raise ArgumentError.new("id not found #{id.inspect}")
      else
        store.fetch id, default
      end

      default = @default
      color = store.fetch id, false

      if found
        found
      elsif default
        default
      else
        raise ArgumentError.new "#{self.class}#get color id not found #{id.inspect}"
      end
    end

    def for(ids : Array(String)) : Colors | Nil
      default = @default
      found = nil
      ids.find do |id|
        found = store.fetch id, nil
      end

      if found
        found
      elsif default
        default
      else
        raise ArgumentError.new("#{self.class}#get_any no match found for color ids #{ids.inspect}")
      end
    end

    def [](id : String) : Colors
      store[id]
    end

    def []=(id : String, colors : Colors)
      store[id] = colors || raise ArgumentError.new("key cannot be nil")
    end
  end

  def self.reset
    Colors.new.set style: "normal"
  end
end

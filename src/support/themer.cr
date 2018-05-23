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
  alias C256  = String | Nil

  class Color
    property codes : String | Nil
    property style : STYLE
    property fg    : CTrue
    property bg    : CTrue
    property fg16  : C16
    property bg16  : C16
    property fg256 : C256
    property bg256 : C256

    def set(
      style : STYLE = nil,
      fg    : CTrue = nil, bg    : CTrue = nil,
      fg16  : C16   = nil, bg16  : C16   = nil,
      fg256 : C256  = nil, bg256 : C256  = nil
    )

      @style = style if style && !style.empty?
      @fg    = fg    if fg    && !fg.empty?
      @bg    = bg    if bg    && !bg.empty?
      @fg16  = fg16  if fg16  && !fg16.empty?
      @bg16  = bg16  if bg16  && !bg16.empty?
      @fg256 = fg256 if fg256 && !fg256.empty?
      @bg256 = bg256 if bg256 && !bg256.empty?

      self # return self for chaining
    end

    def codes
      @codes ||= codes_for(color_depth: 16_000_000)
    end

    def codes_for(color_depth : Int32)
      new_codes = Array(String).new

      if style
        new_codes << "#{s style}"
      end

      if fg && color_depth > 256
        new_codes << "38;2;#{ct fg}"
      elsif fg256 && color_depth > 16
        new_codes << "38;5;#{fg256}"
      elsif fg16 && color_depth > 0
        new_codes << "3#{c16 fg16}"
      end

      if bg && color_depth > 256
        new_codes << "48;2;#{ct bg}"
      elsif bg256 && color_depth > 16
        new_codes << "48;5;#{bg256}"
      elsif bg16 && color_depth > 0
        new_codes << "4#{c16 bg16}"
      end

      "\e[" + new_codes.join(";") + "m"
    end

    def s(name : STYLE)
      STYLES.index name || raise "style not found: #{name.inspect}"
    end

    def c16(name : C16)
      COLORS.index name || 0
    end

    def ct(indicator : CTrue)
      indicator ? hex indicator : raise "hex color indicator not valid: #{indicator}"
    end

    def hex(hexcode : String)
      raise ArgumentError.new "invalid hex color #{hexcode.inspect}" unless hexcode[0] == '#' && hexcode.size == 7
      r = hexcode[1,2].to_i(16)
      g = hexcode[3,2].to_i(16)
      b = hexcode[5,2].to_i(16)
      "#{r};#{g};#{b}"
    end

    def to_s(io)
      io << codes
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
    }.to_h.delete_if {|_,v| !v || v.empty? }
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
      color = Color.new.set style: style,
        fg:    fg,    bg:    bg,
        fg16:  fg16,  bg16:  bg16,
        fg256: fg256, bg256: bg256
      @theme[id] = color
      @theme
    end

    def default(
      style : STYLE | Symbol = nil,
      fg    : CTrue = nil, bg    : CTrue = nil,
      fg16  : C16   = nil, bg16  : C16   = nil,
      fg256 : C256  = nil, bg256 : C256  = nil
    )
      @theme.default = Color.new.set style: style,
        fg:    fg,    bg:    bg,
        fg16:  fg16,  bg16:  bg16,
        fg256: fg256, bg256: bg256
    end
  end

  class Theme
    property colormap = Hash(String, Color).new
    property reset : Color = Color.new.set style: "normal"
    property default : Color | Nil

    def self.load(filename)
      yaml = Hash(String, Hash(String, CTrue | C256 | C16)).new

      File.open filename do |file|
        yaml = YAML.parse(file)#.as Hash
        #(String, Hash(String, String | Int8 | Nil))
      end

      per_def = nil
      data = Hash(String, Color).new
      yaml.each do |k,v|
        colors = Color.new.tap do |c|
          c.set style: v["style"]?.to_s,
            fg:    v["fg"]?.to_s,    bg:    v["bg"]?.to_s,
            fg16:  v["fg16"]?.to_s,  bg16:  v["bg16"]?.to_s,
            fg256: v["fg256"]?.to_s, bg256: v["bg256"]?.to_s
        end

        if k.to_s == "DEFAULT"
          per_def = colors
        else
          data[k.to_s] = colors
        end
      end

      self.new.tap do |t|
        t.default = per_def if per_def
        t.colormap = data
      end
    end

    def save(filename)
      per_def = @default
      per = colormap.dup
      per["DEFAULT"] = per_def if per_def
      File.open filename, mode: "w" do |file|
        file.puts YAML.dump per
      end
    end

    def for(id : String) : Color
      colormap[id]? || raise ArgumentError.new "#{self.class}#for(String) color id not found #{id.inspect}"
    end

    def for(ids : Array(String)) : Color
      found = nil
      ids.find do |id|
        found = colormap.fetch id, nil
      end

      found || @default || raise ArgumentError.new("#{self.class}#for(Array) no match found for color ids #{ids.inspect}")
    end

    def [](id : String) : Color
      colormap[id]
    end

    def []=(id : String, color : Color)
      colormap[id] = color || raise ArgumentError.new("key cannot be nil")
    end
  end

  def self.reset
    Color.new.set style: "normal"
  end
end

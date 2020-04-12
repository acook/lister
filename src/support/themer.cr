require "yaml"

module Themer
  def self.build
    td = Builder.new
    new_theme = with td yield td
    new_theme
  end

  alias StrNil = String | Nil

  class Color
    property codes : StrNil

    property style : StrNil
    property fg    : StrNil
    property bg    : StrNil

    property style16 : StrNil
    property fg16    : StrNil
    property bg16    : StrNil

    property style256 : StrNil
    property fg256    : StrNil
    property bg256    : StrNil

    def set(
      style    : StrNil = nil, fg    : StrNil = nil, bg    : StrNil = nil,
      style16  : StrNil = nil, fg16  : StrNil = nil, bg16  : StrNil = nil,
      style256 : StrNil = nil, fg256 : StrNil = nil, bg256 : StrNil = nil
    )

      @style = style if style && !style.empty?
      @fg    = fg    if fg    && !fg.empty?
      @bg    = bg    if bg    && !bg.empty?

      @style16 = style16 if style16 && !style16.empty?
      @fg16    = fg16    if fg16    && !fg16.empty?
      @bg16    = bg16    if bg16    && !bg16.empty?

      @style256 = style256 if style256 && !style256.empty?
      @fg256    = fg256    if fg256    && !fg256.empty?
      @bg256    = bg256    if bg256    && !bg256.empty?

      self # return self for chaining
    end

    def codes
      @codes ||= codes_for(color_depth: 16_000_000)
    end

    def codes_for(color_depth : Int32)
      new_codes = Array(String).new

      if style && color_depth > 256
        new_codes << "#{s style}" unless style == "none"
      elsif style256 && color_depth > 16
        new_codes << "#{s style256}" unless style256 == "none"
      elsif style16 && color_depth > 0
        new_codes << "#{s style16}" unless style16 == "none"
      end

      if fg && color_depth > 256
        new_codes << "38;2;#{ct fg}" unless fg == "none"
      elsif fg256 && color_depth > 16
        new_codes << "38;5;#{fg256}" unless fg256 == "none"
      elsif fg16 && color_depth > 0
        new_codes << "3#{c16 fg16}" unless fg16 == "none"
      end

      if bg && color_depth > 256
        new_codes << "48;2;#{ct bg}" unless bg == "none"
      elsif bg256 && color_depth > 16
        new_codes << "48;5;#{bg256}" unless bg256 == "none"
      elsif bg16 && color_depth > 0
        new_codes << "4#{c16 bg16}" unless bg16 == "none"
      end

      # this should just be ";" but some terminals can't handle true color fg and bg in a single go
      new_codes_string = new_codes.join("m\e[")
      new_codes_string.empty? ? "" : "\e[" + new_codes_string + "m"
    end

    def s(name : StrNil)
      STYLES.index name || raise "style not found: #{name.inspect}"
    end

    def c16(name : StrNil)
      COLORS.index name || raise "color16 not found: #{name.inspect}"
    end

    def ct(indicator : StrNil)
      indicator ? hex indicator : raise "hex color indicator not valid: #{indicator}"
    end

    def hex(hexcode : String)
      raise ArgumentError.new "invalid hex color #{hexcode.inspect}" unless hexcode[0] == '#' && hexcode.size == 7
      r = hexcode[1,2].to_i(16)
      g = hexcode[3,2].to_i(16)
      b = hexcode[5,2].to_i(16)
      "#{r};#{g};#{b}"
    end

    def empty?(color_depth = 16_000_000)
      codes_for(color_depth).empty?
    end

    def to_s(io)
      io << codes
    end

    def to_hash
      {
        style:    style,    fg:    fg,    bg: bg,
        style256: style256, fg256: fg256, bg256: bg256,
        style16:  style16,  fg16:  fg16,  bg16: bg16
      }.to_h.delete_if { |_,v| !v || v.empty? }
    end

    def to_yaml(*args)
      to_hash.to_yaml *args
    end

    COLORS = %w[black red green yellow blue magenta cyan white extended default]
    STYLES = %w[normal bold faint italic underlined blink blink_fast inverse conceal crossed_out]
  end

  class Builder
    property theme = Theme.new

    def for(id : String, **args)
      color = Color.new.set **args
      @theme[id] = color
      @theme
    end

    def default(**args)
      @theme.default = Color.new.set(**args)
    end
  end

  class Theme
    property colormap = Hash(String, Color).new
    property reset : Color = Color.new.set style: "normal"
    property default : Color | Nil

    def self.load(filename)
      yaml = Hash(String, Hash(String, StrNil | StrNil | StrNil)).new

      File.open filename do |file|
        yaml = YAML.parse(file).as_h
      end

      per_def = nil
      data = Hash(String, Color).new
      yaml.each do |k,v|
        colors = Color.new.tap do |c|
          c.set \
            style:    v["style"]?.to_s,    fg:    v["fg"]?.to_s,    bg:    v["bg"]?.to_s,
            style16:  v["style16"]?.to_s,  fg16:  v["fg16"]?.to_s,  bg16:  v["bg16"]?.to_s,
            style256: v["style256"]?.to_s, fg256: v["fg256"]?.to_s, bg256: v["bg256"]?.to_s
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
        found = Color.new if id == "none"
        found
      end

      found || @default || raise ArgumentError.new("#{self.class}#for(Array) no match found for color ids #{ids.inspect}")
    end

    # the start of a new category of methods which will handle more use cases I've discovered
    # #all(ids)    -> returns all matching colors from the input list
    # #first(ids)  -> returns the first non-empty color from the input list or raises an error
    # #first?(ids) -> returns the first non-empty color from the input list or nil
    # #sum(ids)    -> returns a Color generated by combining all colors from the list, first takes precedence
    def all(ids : Array(String)) : Array(Color)
      ids.each_with_object(Array(Color).new) do |id, acc|
        if color = colormap.fetch id, nil
          acc << color
        elsif id == "none"
          acc << Color.new
        end
      end
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

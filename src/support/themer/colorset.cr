module Themer
  struct Colorset
    COLORS = %w[black red green yellow blue magenta cyan white extended default]
    STYLES = %w[normal bold faint italic underlined blink blink_fast inverse conceal crossed_out]
    TRUECOLOR = 16_000_000

    property style : StrNil
    property fg : StrNil
    property bg : StrNil

    property style16 : StrNil
    property fg16 : StrNil
    property bg16 : StrNil

    property style256 : StrNil
    property fg256 : StrNil
    property bg256 : StrNil

    def initialize(
      @style : StrNil = nil, @fg : StrNil = nil, @bg : StrNil = nil,
      @style16 : StrNil = nil, @fg16 : StrNil = nil, @bg16 : StrNil = nil,
      @style256 : StrNil = nil, @fg256 : StrNil = nil, @bg256 : StrNil = nil
    )
    end

    # calculate the codes for a given color depth
    # a value of "skip" means to stop processing that element type
    def codes(color_depth : Int32 = TRUECOLOR)
      new_codes = Array(String).new
      weight = 0 # for tracking if true-color fg and bgs are both provided

      if style && color_depth > 256
        new_codes << "#{s style}" unless style == "skip"
      elsif style256 && color_depth > 16
        new_codes << "#{s style256}" unless style256 == "skip"
      elsif style16 && color_depth > 0
        new_codes << "#{s style16}" unless style16 == "skip"
      end

      if fg && color_depth > 256
        weight += 1
        new_codes << "38;2;#{ct fg}" unless fg == "skip"
      elsif fg256 && color_depth > 16
        new_codes << "38;5;#{fg256}" unless fg256 == "skip"
      elsif fg16 && color_depth > 0
        new_codes << "3#{c16 fg16}" unless fg16 == "skip"
      end

      if bg && color_depth > 256
        weight += 1
        new_codes << "48;2;#{ct bg}" unless bg == "skip"
      elsif bg256 && color_depth > 16
        new_codes << "48;5;#{bg256}" unless bg256 == "skip"
      elsif bg16 && color_depth > 0
        new_codes << "4#{c16 bg16}" unless bg16 == "skip"
      end

      # the sep should just be ";" but some terminals can't handle true color fg and bg in a single go
      sep = weight > 1 ? "m\e[" : ";"
      new_codes_string = new_codes.join(sep)

      if new_codes_string.empty?
        new_codes_string
      else
        "\e[" + new_codes_string + "m"
      end
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
      r = hexcode[1, 2].to_i(16)
      g = hexcode[3, 2].to_i(16)
      b = hexcode[5, 2].to_i(16)
      "#{r};#{g};#{b}"
    end

    def ==(other : self)
      self.to_hash == other.to_hash
    end

    def empty?(color_depth = 16_000_000)
      codes_for(color_depth).empty?
    end

    def to_s(io)
      io << codes
    end

    def to_hash
      {
        :style => style, :fg => fg, :bg => bg,
        :style256 => style256, :fg256 => fg256, :bg256 => bg256,
        :style16 => style16, :fg16 => fg16, :bg16 => bg16,
      }.reject! { |_, v| !v || v.empty? }
    end

    def to_yaml(*args)
      to_hash.to_yaml *args
    end
  end
end

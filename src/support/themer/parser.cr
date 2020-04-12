module Themer
  module Parser
    def self.parse(code : String) : ThemeColors | NoReturn
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

    class ThemeColors
      property bg : COLOR
      property fg : COLOR
      property style : STYLE
    end
  end
end

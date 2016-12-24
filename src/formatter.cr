require "./theme"

module Lister
  class Formatter
    property root : Entry

    def initialize(root)
      @root = root
    end

    def render(options, parent_longest = 0)
      render_recurse @root, options.recurse, parent_longest
    end

    def render_recurse(entry, recurse_depth, parent_longest, indent = 0)
      unless entry.children_count > 0
        line entry, parent_longest, indent
      else
        line entry, parent_longest, indent
        entry.children.each do |child|
          render_recurse child, (recurse_depth - 1), entry.longest, (indent + 1)
        end unless recurse_depth < 1
      end
    end

    def line(entry, longest, indent)
      text = [indentation(indent), entry.name.ljust(longest), div, entry.type].join
      if text.size > console_width
        text = text[0,(console_width-1)] + "…"
      end
      print Theme.new(entry).color, text, Theme.reset_line, "\n"
    end

    def indentation(size)
      " " * (size * 2)
    end

    def div
      "  "
    end

    def console_width
      # FIXME: Crystal doesn't support Array packing
      #tiocgwinsz = 0x40087468
      #str = [0, 0, 0, 0].pack("SSSS")
      #unless STDOUT.ioctl(tiocgwinsz, str) < 0
      #  str.unpack("SSSS")[1]
      #else
      Int8::MAX
      #end
    end
  end
end

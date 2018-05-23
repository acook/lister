require "./file_type"

module Lister
  class Formatter
    def self.list_types(options)
      FT::DEFAULT_TYPES.keys.sort.map do |type|
        options.theme.for(FT.match(type.to_s).flatten).to_s + type.to_s + options.theme.reset.to_s
      end.join(", ")
    end

    property root : Entry
    property options : Options

    def initialize(root, options)
      @root = root
      @options = options
    end

    def render(parent_longest = 0)
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
      info = [indentation(indent), entry.name.ljust(longest), div]
      if options.show_type_names
        typeinfo = FT.match(entry.type).reduce(Array(String).new) do |acc, types|
          acc << (types.is_a?(Array) ? types : [types]).reverse.join("/")
        end

        info += [typeinfo.join(", ")]
      elsif options.show_mime_types
        info += [entry.mime]
      else
        info += [entry.type]
      end
      text = info.join
      if text.size > console_width
        text = text[0,(console_width-1)] + "…"
      end
      print color(entry), text, options.theme.reset, "\n"
    end

    def color(entry)
      types = FT.match do |r|
        r =~ entry.type
      end

      options.theme.for(types.flatten).codes_for(options.palette)
    end

    def indentation(size)
      " " * (size * 2)
    end

    def div
      "  "
    end

    def console_width
      options.terminal.width
    end
  end
end

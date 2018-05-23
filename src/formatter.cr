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
      nonvisible = ""
      sigil = ""

      info = Array(String).new
      info << indentation(indent)

      info << entry.name
      info << (nonvisible += attr_color entry)
      info << (sigil += attr entry)
      info << (color(entry).to_s.tap{ |c| nonvisible += c })

      info << just entry.name + sigil, longest + 1
      info << div

      info << type_info entry

      text = info.join

      if text.size - nonvisible.size > console_width
        text = text[0,(console_width-1)] + "…"
      end

      # inject color codes at this point instead of earlier

      print color(entry), text, options.theme.reset, "\n"
    end

    def just(text, fit, fill = " ")
      if text.size >= fit
        ""
      else
        fill * (fit - text.size)
      end
    end

    def attr(entry) : String
      case
      when entry.path.symlink?
        "@"
      when entry.path.directory?
        "/"
      when entry.path.executable?
        "*"
      else
        ""
      end
    end

    def attr_color(entry) : String
      attr_types = FT.match(fallback: ["none"]) { |r| r =~ attr(entry) }
      options.theme.for(attr_types.flatten).codes_for(options.palette)
    end

    def type_info(entry)
      if options.show_type_names
        type_names entry
      elsif options.show_mime_types
        entry.mime
      else
        entry.type
      end
    end

    def type_names(entry)
      typeinfo = FT.match(entry.type).reduce(Array(String).new) do |acc, types|
        acc << (types.is_a?(Array) ? types : [types]).reverse.join("/")
      end

      typeinfo.join(", ")
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

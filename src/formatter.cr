require "./file_type"

module Lister
  class Formatter
    def self.list_types(options)
      FT::DEFAULT_TYPES.keys.sort.map do |type|
        options.theme.for(FT[type].list).codes(options.palette) + type.to_s + options.theme.reset.to_s
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
      register_recurse entry do
        line entry, parent_longest, indent
        if entry.children.size > 0 && recurse_depth > 0
          entry.children.each do |child|
            render_recurse child, (recurse_depth - 1), entry.longest, (indent + 1)
          end
        end
      end
    end

    def line(entry, longest, indent)
      info = String.new

      info += entry.name
      pre_sigil = info.size
      info += entry.sigil
      post_sigil = info.size

      info += just info.size, longest + 1
      info += div

      info += type_info entry

      info_width = info.size + (indent * 2)
      if info_width > console_width
        truc_width = console_width - (indent * 2) - 1
        info = info[0, truc_width] + "…"
      end

      # inject the color codes so we don't have to worry about them earlier
      info = info.insert post_sigil, color(entry)
      info = info.insert pre_sigil, sigil_color(entry)

      print color(entry), "\e[K" if options.full_line
      print indentation(indent), color(entry), info, options.theme.reset, "\n"
    end

    def just(len, fit, fill = " ")
      if len >= fit
        ""
      else
        fill * (fit - len)
      end
    end

    def sigil_color(entry) : String
      options.theme.for([entry.sigil]).codes(options.palette)
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
        acc << (types.is_a?(Array) ? types.reverse.join("/") : types)
      end

      typeinfo.join(", ")
    end

    def color(entry)
      types = FT.match do |r|
        r =~ entry.type
      end

      options.theme.for(types.flatten).codes(options.palette)
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

    def register_recurse(entry)
      inode = entry.fp.inode

      reg = @@registry ||= Set(UInt64).new

      if reg.includes? inode
        "[RECURSIVE DIRECTORY #{entry.name}]"
      else
        reg << inode
        retval = yield
        reg.delete inode
        retval
      end
    end
  end
end

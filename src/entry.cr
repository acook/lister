

module Lister
  class Entry
    include Comparable(Entry)

    property path : Pathname
    property children = Array(Entry).new
    property children_count = 0
    property raw_children = Array(Pathname).new
    property type = "(unknown)"
    property longest : Int32
    property options : Options

    def initialize(path_string, options)
      @path = Pathname.new path_string
      @longest = path.path.size
      @options = options
    end

    def type
      if @type != "(unknown)"
        @type
      elsif path.exists?
        info = options.magic.file path.to_s
        stripped_info = info.gsub(/^#{path.to_s}:\s+/, "").strip

        @type = stripped_info
      else
        @type = "(FILE NOT FOUND)"
      end
    end

    def children
      Array(Entry).new
    end

    def name
      @path.expand_path.basename.to_s
    end

    def <=>(other)
      self.name <=> other
    end
  end

  class Directory < Entry
    def initialize(*args)
      super *args

      @raw_children = path.children || Array(Pathname).new

      @children_count = raw_children.size
      #rescue Errno::EACCES
      #  -1

      if children_count > 0
        @longest = raw_children.map{|c| c.basename.to_s.size }.max
      end
    end

    def children
      dirs  = Array(Directory).new
      files = Array(Entry).new
      raw_children.sort.each do |child|
        if child.directory?
          dirs.push Directory.new child, options
        else
          files.push Entry.new child, options
        end
      end

      files + dirs
    end

    def type
      if children_count > 0
        super + " (#{children_count})"
      elsif children_count == 0
        super + " (empty)"
      elsif children_count < 0
        super + " (permission denied)"
      else
        super + " (unknown)"
      end
    end
  end
end

module Lister
  class Entry
    include Comparable(Entry)

    property path : Pathname
    property children = Array(Entry).new
    property children_count = 0
    property raw_children = Array(Pathname).new
    property type = "(unknown)"
    property longest : Int32

    def initialize(path_string)
      @path = Pathname.new path_string
      @longest = path.path.size
    end

    def type
      if @type
        @type
      elsif path.exists?
        @type = %x[file '#{path}'].gsub(/^#{path}:\s+/, "").strip
      else
        @type = "(FILE NOT FOUND)"
      end
    end

    def children
      Array(Entry).new
    end

    def directory?
      self.class == Directory
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
    end

    def children
      @children ||= get_children
    end

    def children_count
      @children_count ||= raw_children.size
    #rescue Errno::EACCES
    #  -1
    end

    def get_children
      dirs  = Array(Directory).new
      files = Array(Entry).new
      raw_children.sort.each do |child|
        if child.directory?
          dirs.push Directory.new child
        else
          files.push Entry.new child
        end
      end

      files + dirs
    end

    def longest
      @longest ||= children.map{|c| c.name.size }.max
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

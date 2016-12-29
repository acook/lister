module Lister
  # the Entry class represents a single file in a directory
  # it wraps the Pathname object which is essentially just
  #   convinience methods over String, File, and Dir
  class Entry
    include Comparable(Entry)

    property path : Pathname
    property children = Array(Entry).new
    property children_count = 0
    property raw_children = Array(Pathname).new
    property type : String
    property longest : Int16
    property options : Options

    def initialize(path_string, options)
      @path = Pathname.new path_string
      @longest = path.path.size.to_i16
      @options = options

      if path.exists? || path.symlink?
        # broken symlinks return false from exists? but
        # libmagic still provides useful info for them
        raw_info      = options.magic.file path.to_s
        stripped_info = raw_info.sub(/^#{path.to_s}:\s+/, "").strip

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

      begin
        @raw_children = path.children || Array(Pathname).new
        @children_count = raw_children.size

        if children_count > 0
          @longest = raw_children.map{|c| c.basename.to_s.size }.max.to_i16
        end
      rescue err : Errno
        raise err unless err.errno == Errno::EACCES

        @raw_children = Array(Pathname).new
        @children_count = -1
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
      elsif children_count == -1
        super + " (permission denied)"
      else
        super + " (unknown)"
      end
    end
  end
end

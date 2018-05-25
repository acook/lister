module Lister
  # the Entry class represents a single file in a directory
  # it wraps the Pathname object which is essentially just
  #   convinience methods over String, File, and Dir
  class Entry
    # this combined with <=> makes Entries sortable
    include Comparable(Entry)

    property path : Pathname
    property children = Array(Entry).new
    property children_count = 0
    property raw_children = Array(Pathname).new
    property type : String
    property mime : String
    property longest : Int16
    property options : Options

    def initialize(path_string, options)
      @path = Pathname.new path_string
      @longest = path.path.size.to_i16
      @options = options

      # broken symlinks return false from exists? but
      # libmagic still provides useful info for them
      if path.exists? || path.symlink?
        raw_type = options.magic.file path.to_s
        # remove the full path prefix from libmagic's result
        @type = raw_type.sub(/^#{path}:\s+/, "").strip
        @mime = options.magic_mime.file path.to_s
      else
        # this will happen if the user specifies a nonexistent file
        @type = "(FILE NOT FOUND)"
        @mime = "(FILE NOT FOUND)"
      end
    end

    # normal Entry objects don't have Children, so return an empty array
    def children
      Array(Entry).new
    end

    def name
      @path.expand_path.basename.to_s
    end

    # sort files by name
    # this will probably be configurable later
    def <=>(other)
      self.name <=> other
    end
  end

  class Directory < Entry
    def initialize(*args)
      super *args

      begin
        @raw_children = path.children(options.show_hidden) || Array(Pathname).new

        if path.symlink?
          @children_count = -1
        else
          @children_count = raw_children.size
        end

        if children_count > 0
          @longest = raw_children.map{|c| c.basename.to_s.size }.max.to_i16
        end
      rescue err : Errno
        raise err unless err.errno == Errno::EACCES

        # if we get here it's because we don't have the permissions
        #   to access this directory, set this so we can use it later
        @children_count = -1
      end
    end

    # get the files in this directory
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

      # this ensures that directories are listed last
      files + dirs
    end

    # suffix information about the directory onto the type
    def type
      if children_count > 0
        super + " (#{children_count})"
      elsif children_count == 0
        super + " (empty)"
      elsif children_count == -1 && path.symlink?
        super + " (#{path.entries.size})"
      elsif children_count == -1
        super + " (permission denied)"
      else
        super + " (unknown)"
      end
    end
  end
end

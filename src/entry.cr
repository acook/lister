module Lister
  # Builds Entry objects from a given path using a libMagic engine
  # usage:
  #   ef = EntryFactory.new LibMagic.new
  #   entry = ef.build "path"
  class EntryFactory
    property engine : MagicEngine

    def initialize(@engine)
    end

    def build(uri) : Entry
      exists = ::File.exists? uri
      info = ::File.info? uri
      type = info.type unless info.nil?

      case
      when type.nil? && File.symlink? uri
          Entry::Symlink.new uri, info, self
      when type.nil? && !exists
          Entry::NotFound.new uri, info, self
      when type.nil?
        Entry::Unknown.new uri, info, self
      when type.symlink?
        Entry::Symlink.new uri, info, self
      when type.directory?
        Entry::Directory.new uri, info, self
      when type.pipe?
        Entry::Pipe.new uri, info, self
      when type.socket?
        Entry::Socket.new uri, info, self
      when type.device?
        Entry::Device.new uri, info, self
      when type.file?
        Entry::File.new uri, info, self
      else
        Entry::Unknown.new uri, info, self
      end
    end
  end

  # the Entry class represents an abstraction of all files and directories
  abstract class Entry
    # this combined with <=> makes Entries sortable
    include Comparable(Entry)

    property name : String
    property path : Path
    property info : ::File::Info | Nil
    property fullpath : String | Nil
    property children = Array(Entry).new
    property longest : Int16 | Nil
    property type : String | Nil
    property mime : String | Nil
    property factory : EntryFactory

    def initialize(path_string, path_info = nil, factory = EntryFactory.new)
      @path = Path.new path_string
      @name = path.basename.to_s
      @info = path_info
      @factory = factory
    end

    # sort files by name
    # this will probably be configurable later
    def <=>(other)
      name <=> other
    end

    def type
      @type ||= factory.engine.type self.fullpath
    end

    def mime
      @mime ||= factory.engine.mime self.fullpath
    end

    def fullpath
      @fullpath ||= ::File.expand_path path
    end

    def longest
      @longest ||= name.size.to_i16
    end

    def executable?
      ::File.executable? fullpath
    end

    def reset
      @type = nil
      @mime = nil
      @fullpath = nil
      @longest = nil
      @info = ::File.info fullpath
    end

    class File < Entry
    end

    class Symlink < Entry
    end

    class Pipe < Entry
    end

    class Socket < Entry
    end

    class Device < Entry
    end

    class Unknown < Entry
    end

    class NotFound < Entry
      def type
        "(FILE NOT FOUND)"
      end

      def mime
        "(FILE NOT FOUND)"
      end

      def fullpath
        @fullpath ||= path.to_s
      end

      def name
        path.basename.to_s
      end
    end

    class Directory < Entry
      def children
        return @children unless @children.empty?

        skip = [".", ".."]

        children = Array(Entry).new
        begin
          Dir.open(fullpath) do |dir|
            dir.each do |entry|
              next if skip.includes? entry
              children << factory.build ::File.expand_path(entry, fullpath)
            end
          end
        rescue err : ::File::AccessDeniedError
          # if we get here it's because we don't have the permissions
          #   to access this directory, set this so we can use it later
          @children_access_denied = true
        end
        @children = children
      end

      # suffix information about the directory onto the type
      def type
        if children.size > 0
          super + " (#{children.size})"
        elsif children.size == 0
          super + " (empty)"
        #elsif children_count == -1 && info.symlink?
        #  super + " (#{path.entries.size})"
        elsif @children_access_denied
          super + " (permission denied)"
        else
          super + " (unknown)"
        end
      end

      def longest
        @longest ||= children.max_by{|child| child.name.to_s }.name.to_s.size.to_i16
      end
    end
  end

end

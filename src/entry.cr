require "./support/filepath"

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
      fp = FilePath.new uri

      case
      when fp.symlink?
        Entry::Symlink.new fp, self
      when fp.missing?
        Entry::NotFound.new fp, self
      when fp.directory?
        Entry::Directory.new fp, self
      when fp.pipe?
        Entry::Pipe.new fp, self
      when fp.socket?
        Entry::Socket.new fp, self
      when fp.device?
        Entry::Device.new fp, self
      when fp.file?
        Entry::File.new fp, self
      else
        Entry::Unknown.new fp, self
      end
    end
  end

  # the Entry class represents an abstraction of all files and directories
  abstract class Entry
    # this combined with <=> makes Entries sortable
    include Comparable(Entry)

    property fp : FilePath
    property fullpath : String | Nil
    property children = Array(Entry).new
    property longest : Int16 | Nil
    property magic : String | Nil
    property mime : String | Nil
    property factory : EntryFactory

    def initialize(@fp, @factory = EntryFactory.new)
    end

    # sort files by name
    # this will probably be configurable later
    def <=>(other)
      name <=> other
    end

    def type
      @magic ||= factory.engine.type self.fullpath
    end

    def mime
      @mime ||= factory.engine.mime self.fullpath
    end

    def fullpath
      @fullpath ||= fp.expand_path.to_s
    end

    def longest
      @longest ||= name.size.to_i16
    end

    def name
      fp.basename.to_s
    end

    def executable?
      fp.executable?
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
        fp.to_s
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
        #elsif children_count == -1 && fp.symlink?
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

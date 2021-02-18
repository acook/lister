require "path"
require "./delegation_macros"

class FilePath
  include DelegationMacros
  include Comparable(self)

  def self.pwd
    new "."
  end

  # this ensures we don't have to fight with the type checker
  def self.wrap(value) : self
    case value
    when String, Path
      new value
    when FilePath
      value
    else
      raise ArgumentError, "can't wrap #{value.class} in #{name}"
    end
  end

  property orig : String
  property path : Path
  property stat : File::Info

  def initialize(new_filepath = ".")
    @orig = new_filepath
    @path = Path[new_filepath]
    fileinfo = File.info? new_filepath
    if fileinfo.nil?
      fileinfo = File.info? new_filepath, false
    end
    @stat = fileinfo.nil? ? FileNotFoundInfo.new : fileinfo
  end

  def children(show_hidden = false)
    return unless directory?
    skip = [
      /^\.$/,
      /^\.\.$/
    ]

    skip << /^\./ unless show_hidden

    children = Array(FilePath).new
    Dir.open(path) do |dir|
      dir.each do |entry|
        next if symlink? || skip.any? {|pattern| pattern =~ entry }
        children << self.class.new File.expand_path(entry, self.expand_path.to_s)
      end
    end
    children
  end

  def restat
    initialize @orig
  end

  def entries
    Dir.entries(path)
  end

  def join(*args)
    ([path.dup].concat args).join PATH_SEP
  end

  def expand_path
    self.class.new File.expand_path path
  end

  def missing?
    !exists?
  end

  def <=>(other)
    path <=> other
  end

  def to_s(io)
    io << path
  end

  def wrap(value)
    self.class.wrap value
  end

  # Like #wrap except is permissive with types and doesn't raise.
  # Primarily for catching useful return values from Path and File
  # which might return multiple types.
  private def retwrap(value)
    case value
    when String, Path
      self.class.new value
    when FilePath
      # I think this dup here is because it makes it easier to do before/after versions of file info
      # But a better solution might be to make FilePath a struct and immutable
      value.dup
    else
      value
    end
  end

  delegate file?, directory?, symlink?, pipe?, socket?, blockdev?, chardev?, device?, unknown?, to: @stat.type
  delegate_attr exists?, executable?, to: File, using: @path

  macro method_missing(call)
    retwrap path.{{call}}
  end

  struct FileNotFoundInfo < ::File::Info
    def size : Int64
      0_i64
    end

    def permissions : ::File::Permissions
      ::File::Permissions.new 0
    end

    def type : ::File::Type
      ::File::Type::Unknown
    end

    def flags : ::File::Flags
      ::File::Flags::None
    end

    def modification_time : Time
      Time.unix 0
    end

    def owner_id : String
      ""
    end

    def group_id : String
      ""
    end

    def same_file?(other) : Bool
      false
    end
  end
end

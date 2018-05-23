class Pathname
  include Comparable(Pathname)

  # TODO: When Crystal supports Windows, detect it and use backslash here
  PATH_SEP = '/'

  def self.pwd
    self.new "."
  end

  property path : String

  def initialize(new_path)
    case new_path
    when Pathname
      @path = new_path.path
    when String
      @path = new_path
    else
      raise "invalid path supplied"
    end
  end

  def basename
    self.class.new File.basename path
  end

  def directory?
    File.directory? path
  end

  def children(show_hidden = false)
    return unless directory?
    skip = [
      /^\.$/,
      /^\.\.$/
    ]

    skip << /^\./ unless show_hidden

    children = Array(Pathname).new
    Dir.open(path) do |dir|
      dir.each do |entry|
        next if skip.any? {|pattern| pattern =~ entry }
        children << self.class.new self.join entry
      end
    end
    children
  end

  def join(*args)
    ([path.dup].concat args).join PATH_SEP
  end

  def expand_path
    self.class.new File.expand_path path
  end

  def exists?
    File.exists? path
  end

  def symlink?
    File.symlink? path
  end

  def executable?
    File.executable? path
  end

  def <=>(other)
    path <=> other.path
  end

  def to_s
    path
  end
end

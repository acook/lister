class Pathname
  include Comparable(Pathname)

  # TODO: When Crystal supports Windows, detect it and use backslash here
  PATH_SEP = '/'

  def self.pwd
    self.new "."
  end

  property path : String
  property stat : File::Info | Nil

  def initialize(new_path : String | Pathname, no_stat = false)
    @path = new_path.to_s
    @stat = nil

    restat unless no_stat
  end

  def basename
    self.class.new File.basename(path), no_stat: true
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
        next if symlink? || skip.any? {|pattern| pattern =~ entry }
        children << self.class.new File.expand_path(entry, self.expand_path.to_s)
      end
    end
    children
  end

  def entries()
    Dir.entries(path)
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

  def restat
    begin
      @stat = File.info File.expand_path path
    rescue ex : File::NotFoundError # don't freak out if the path doesn't exist
      puts "file not found : #{File.expand_path path}"
    end
    !!@stat
  end

  def pipe?
    (s = stat) && s.type.pipe?
  end

  def socket?
    (s = stat) && s.type.socket?
  end

  def blockdev?
    (s = stat) && s.type.blockdev?
  end

  def chardev?
    (s = stat) && s.type.chardev?
  end

  def <=>(other)
    path <=> other.path
  end

  def to_s
    path
  end

  def to_s(io)
    io << path
  end
end

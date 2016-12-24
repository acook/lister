#require "libmagic-crystal/magic"

require "./support/pathname"
require "./formatter"
require "./entry"

module Lister
  class CLI
    property options = Options.new
    property paths = Array(String).new

    def parse_args(args)
      skip = nil
      @paths = args.each_with_object(Array(String).new).with_index do |(arg, path_list), i|
        if arg == "-r"
          @options.recurse = Int8::MAX
        elsif arg == "--recurse"
          @options.recurse += args[i + 1].to_i
          skip = i + 1
        elsif %w[-h --help].includes? arg
          usage
        elsif skip != i
          path_list << arg
        end
      end || Array(String).new

      self # make chainable since there is no meaningful return value
    end

    def run
      longest = paths.map{|path| path.size }.max

      paths.each do |path|
        Formatter.new(wrap path).render @options, longest
      end

    ensure
      print Theme.reset_line
    end

    def paths
      if @paths.empty?
        @paths = [Pathname.pwd.to_s]
      else
        @paths
      end
    end

    def wrap(path)
      path = Pathname.new path
      if path.directory?
        Directory.new path
      else
        Entry.new path
      end
    end

    def usage
      # FIXME: Crystal lacks $0 ?
      #this = Pathname.new($0 || "lister").basename
      this = "lister"

      puts "usage: #{this} [-r] [--recurse DEPTH] [<paths>]"
      puts "\tshows colorized and structured libmagic types"
      puts
      puts "\t-r\trecurse infinite"
      puts "\t--recurse DEPTH\t recurse to depth"
      puts "\t-h\tshow this help"
      puts "\t<paths>\ta list of zero or more paths"
      puts "\t\twill scan PWD if no path supplied"
      exit 0
    end
  end

  class Options
    property recurse : Int8 = 1_i8

    def recurse=(depth)
      @recurse = depth
    end

    def recurse?
      @recurse > 0
    end

    def magic
      # the default flag sets it to onl return MIME types,
      # which is an extremely limited subset of possible types
      #flags = Magic::LibMagic::Flags::NONE.to_i
      # this version also search inside compressed files
      #flags = Magic::LibMagic::Flags::COMPRESS.to_i
      #magic = Magic::Magic.new flags: flags

      # the below line needs to be moved to Entry
      #magic.file(ARGV.first)
    end
  end
end

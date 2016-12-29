require "libmagic-crystal/magic"

require "./support/pathname"
require "./support/terminal"
require "./formatter"
require "./entry"

module Lister
  class CLI
    property options = Options.new
    property paths = Array(String).new

    # this is the method which starts the ball rolling
    # but if #parse_args hasn't been run it will implode
    def run
      longest = paths.map{|path| path.size }.max

      paths.each do |path|
        Formatter.new(wrap(path), options).render longest
      end

    ensure
      # make sure we don't make a mess of the terminal colors
      print Themer.reset
      # HACK: The following is a result of a major bug in Crystal
      # https://github.com/crystal-lang/crystal/issues/2065
      STDOUT.blocking = true
      STDERR.blocking = true
    end

    # this does a hack job of parsing commandline arguments
    def parse_args(args)
      skip = nil
      args.each.with_index do |arg, i|
        if arg == "-r"
          @options.recurse = Int8::MAX
        elsif arg == "--recurse"
          @options.recurse += args[i + 1].to_i
          skip = i + 1
        elsif %w[-h --help].includes? arg
          usage
        elsif skip != i
          @paths << arg
        end
      end

      # search the current directory if nothing else
      @paths << "." if @paths.empty?

      self # make chainable since there is no meaningful return value
    end


    def wrap(path)
      if File.directory? path
        Directory.new path, options
      else
        Entry.new path, options
      end
    end

    def usage
      this = Pathname.new(PROGRAM_NAME).basename.to_s

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

  # the Options object is essentially an environment which gets passed around
  #   in lieu of globals or tons of extraneous arguments
  # this object stores the commandline options and the interface to libmagic
  class Options
    property recurse : Int8 = 1_i8
    property magic : Magic::Magic
    property terminal = Terminal.new

    def initialize
      # the default flags set it to only return MIME types,
      #   which is an extremely limited subset of possible types
      #   the below line could be used instead, but
      #   the current flags also search compressed files
      #flags = Magic::LibMagic::Flags::NONE.to_i
      flags = Magic::LibMagic::Flags::COMPRESS.to_i
      @magic = Magic::Magic.new flags: flags
    end

    def recurse?
      @recurse > 0
    end
  end
end

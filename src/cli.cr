require "./support/pathname"
require "./formatter"
require "./entry"
require "./options"

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

    end

    # this does a hack job of parsing commandline arguments
    def parse_args(args)
      skip = nil
      args.each.with_index do |arg, i|
        if arg == "-R"
          @options.recurse = Int8::MAX
        elsif arg == "--recurse"
          @options.recurse += args[i + 1].to_i
          skip = i + 1
        elsif arg == "-A"
          @options.show_hidden = true
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

      puts "usage: #{this} [-A] [-R] [--recurse DEPTH] [<paths>]"
      puts "\tshows colorized and structured libmagic types"
      puts
      puts "\t-A\t\tshow hidden files (excluding . and ..)"
      puts "\t-h\t\tshow this help"
      puts "\t-R\t\trecurse infinite"
      puts "\t--recurse DEPTH\trecurse to depth"
      puts "\t<paths>\t\ta list of zero or more paths"
      puts "\t\t\twill scan PWD if no path supplied"
      exit 0
    end
  end
end

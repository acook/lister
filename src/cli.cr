require "./support/pathname"
require "./formatter"
require "./entry"
require "./options"

module Lister
  class CLI
    property options = Options.new
    property paths = Array(String).new

    # this is the method which starts the ball rolling
    # but if #set_options hasn't been run it will implode
    def run
      longest = paths.map{ |path| path.size }.max

      paths.each do |path|
        Formatter.new(wrap(path), options).render longest
      end

    end

    def set_options(env, args)
      parse_env(env)
      parse_args(args)
      self
    end

    def parse_env(env)
      if theme = env["LISTER_THEME"]?
        @options.theme = Themer::Theme.load theme
      end
      self
    end

    # this does a hack job of parsing commandline arguments
    def parse_args(args)
      skip = nil
      args.each.with_index do |arg, i|
        if arg == "--"
          @paths += args[i..-1]
          return # stop processing commandline arguments
        elsif arg == "-A"
          @options.show_hidden = true
        elsif arg == "--colors"
          @options.theme = Themer::Theme.load args[i + 1]
          skip = i + 1
        elsif arg == "--color-depth"
          depth = args[i + 1]
          if depth == "16"
            @options.palette = 16
          elsif depth == "256"
            @options.palette = 256
          elsif depth.downcase == "true" || depth.downcase == "tc" || depth == "16000000"
            @options.palette = 16_000_000
          else
            puts "unknown argument to --color-depth: #{depth}"
            usage
            exit 1
          end
          skip = i + 1
        elsif %w[-h --help].includes? arg
          usage
          exit 0
        elsif arg == "--list-types"
          puts Formatter.list_types(options)
          exit 0
        elsif arg == "-K"
          @options.show_type_names = true
        elsif arg == "-Km"
          @options.show_mime_types = true
        elsif arg == "-R"
          @options.recurse = Int8::MAX
        elsif arg == "--recurse"
          @options.recurse += args[i + 1].to_i
          skip = i + 1
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
      puts "\t--\t\tstop processing commandline options"
      puts "\t\t\tinterpret remaining arguments as paths"
      puts "\t-A\t\tshow hidden files (excluding . and ..)"
      puts "\t--colors FILE\tuse specified YAML file as color theme"
      puts "\t--color-depth DEPTH\tuse the 16, 256, or true color palette"
      puts "\t-h\t\tdisplay usage information (you're looking at it!)"
      puts "\t-K\t\tshow type names as seen by Lister"
      puts "\t-Km\t\tshow MIME types from libMagic"
      puts "\t--list-types\tdisplay list of known themeable file types"
      puts "\t\t\tin the associated color from the current theme"
      puts "\t-R\t\trecurse infinite"
      puts "\t--recurse DEPTH\trecurse to depth"
      puts "\t<paths>\t\ta list of zero or more paths"
      puts "\t\t\twill scan PWD if no path supplied"
      puts
      puts "\tenvironment variables:"
      puts "\tLISTER_COLORS\tfull path to the Lister theme YAML file"
      puts "\t\t\tcan be overridden on the commandline with --theme"
    end
  end
end

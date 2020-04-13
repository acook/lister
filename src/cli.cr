require "path"
require "./formatter"
require "./entry"
require "./options"

module Lister
  class CLI
    property options = Options.new
    property paths = Array(String).new
    property ef : EntryFactory

    def initialize
      @ef = EntryFactory.new(options.engine)
    end

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
        load_theme env["LISTER_THEME"]
      end
      self
    end

    # this does a hack job of parsing commandline arguments
    def parse_args(args)
      no_run = false
      skip = nil
      args.each.with_index do |arg, i|
        if arg == "--"
          @paths += args[i..-1]
          return # stop processing commandline arguments
        elsif arg == "-A"
          @options.show_hidden = true
        elsif arg == "--colors"
          load_theme args[i + 1]
          skip = i + 1
        elsif arg == "--colors-export"
          path = args[i + 1]
          @options.theme.save path
          skip = i + 1
          puts "Exported internal color theme to: #{path}"
          exit 0 # I assume this is all that makes sense to do
        elsif arg == "--colors-list"
          puts Formatter.list_types(options)
          no_run = true
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
          no_run = true
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

      # exiting here instead of inside the arg parser lets users do things like:
      # `lister --color-depth 16 --list-types --color-depth 256 --list-types`
      exit 0 if no_run

      # search the current directory if nothing else
      @paths << "." if @paths.empty?

      self # make chainable since there is no meaningful return value
    end

    def wrap(path)
      ef.build path
    end

    def load_theme(path)
      if new_theme = Themer::Theme.load path
        @options.theme = new_theme
      else
        Themer.warn "Falling back to default theme!"
      end
    end

    def usage
      this = Path.new(PROGRAM_NAME).basename

      puts "#{this} #{Lister::VERSION}"
      puts "Anthony M. Cook <github@anthonymcook.com>"
      puts "http://github.com/acook/lister"
      puts
      puts "#{this} is a file and directory listing utility which shows colorized and structured libmagic types."
      puts
      puts "USAGE:"
      puts "\t#{this} [OPTIONS] [PATH ...]"
      puts "\t#{this} --colors-export PATH"
      puts "\t#{this} --colors-list"
      puts
      puts "OPTIONS:"
      puts "\t--\t\t\tstop processing commandline options and interpret remaining arguments as paths"
      puts "\t-A\t\t\tshow hidden files (excluding . and ..)"
      puts "\t--colors FILE\t\tuse specified YAML file as color theme"
      puts "\t--colors-export FILE\texport internal color theme as YAML file"
      puts "\t--colors-list\t\tdisplay list of known themeable file types in the associated color from the current theme"
      puts "\t--color-depth DEPTH\tuse the 16, 256, or true color palette"
      #puts "\t--color-line\tfill in the whole line of an entry"
      #puts "\t\t\tusually only the filename and type info is affected"
      puts "\t-h\t\t\tdisplay usage information (you're looking at it!)"
      puts "\t-K\t\t\tshow type names as seen by Lister"
      puts "\t-Km\t\t\tshow MIME types from libMagic"
      puts "\t-R\t\t\trecurse infinite"
      puts "\t--recurse DEPTH\t\trecurse to depth"
      puts "\t<paths>\t\t\ta list of zero or more paths will scan PWD if no path supplied"
      puts
      puts "ENVIRONMENT:"
      puts "\tLISTER_COLORS\t\tfull path to the Lister theme YAML file, can be overridden on the commandline with --colors"
    end
  end
end

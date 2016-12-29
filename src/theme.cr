require "./support/themer"
require "./file_type"

module Lister
  class Theme
    DEFAULT_THEME = Themer.create do
      default style: :normal
      for "broken", bg: :red
      for "directory", style: :bold, fg: :black
      for "source", fg: :white
        for "shell", fg: :magenta
          #for "bash", fg: :green
          #for "zsh", fg: :blue
        for "script", fg: :white
          for "perl", fg: :yellow
          for "ruby", fg: :red
      for "program", fg: :blue
        # x86
        # arm
      for "unix", fg: :yellow
        # link
        # socket
      for "image", style: :bold, fg: :magenta
        # gif
        # jpeg
      for "compressed", style: :bold
        for "doom", style: :bold, fg: :green
    end

    DEFAULT_TYPES = Hash(Regex, FT::Node).new.merge({
      /broken|NOT FOUND|cannot open/ => FT[:broken],
      /directory/        => FT[:directory],
      /link|socket/      => FT[:unix],
      /bash|Bourne/      => FT[:bash],
      /zsh/              => FT[:zsh],
      /shell|SHELL/      => FT[:shell],
      /perl/             => FT[:perl],
      /ruby|Ruby/        => FT[:ruby],
      /python/           => FT[:python],
      /x86|i386/         => FT[:x86],
      /program/          => FT[:program],
      /GIF/              => FT[:gif],
      /doom|PWAD/        => FT[:wad]
    })

    property entry : Entry

    def initialize(entry)
      @entry = entry
    end

    def color
      theme.get_any styles.map{|s| s.to_s.downcase }
    end

    def styles
      types.find do |regex, t|
        if regex =~ @entry.type
          return t.list
        end
      end

      Array(String).new
    end

    def types
      DEFAULT_TYPES
    end

    def theme
      DEFAULT_THEME
    end
  end
end

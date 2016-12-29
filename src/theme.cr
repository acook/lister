require "./support/themer"

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

    enum Types
      Default
      Directory
      Broken

      Source
        Shell
          Bash
          Zsh
        Script
          Ruby
          Perl
          Python
      Program
        X86
        ARM
      Unix
        Link
        Socket
      Image
        GIF
        JPEG
      Compressed
        Zip
        Wad
    end

    DEFAULT_TYPES = Hash(Regex, Array(Types)).new.merge({
      /broken|NOT FOUND|cannot open/ => [Types::Broken],
      /bash|Bourne/      => [Types::Bash, Types::Shell, Types::Source],
      /zsh/              => [Types::Zsh, Types::Shell, Types::Source],
      /shell|SHELL/      => [Types::Shell, Types::Source],
      /perl/             => [Types::Perl, Types::Script, Types::Source],
      /ruby|Ruby/        => [Types::Ruby, Types::Script, Types::Source],
      /python/           => [Types::Python, Types::Script, Types::Source],
      /x86|i386/         => [Types::X86, Types::Program],
      /link|socket/      => [Types::Link, Types::Socket, Types::Unix],
      /directory/        => [Types::Directory],
      /program/          => [Types::Program],
      /GIF/              => [Types::GIF, Types::Image],
      /doom|PWAD/        => [Types::Wad, Types::Compressed],
    })

    property entry : Entry

    def initialize(entry)
      @entry = entry
    end

    def color
      theme.get_any styles.map{|s| s.to_s.downcase }
    end

    def styles
      s = types.find do |regex, styles|
        regex =~ @entry.type
      end
      if s
        s.last
      else
        Array(Types).new
      end
    end

    def types
      DEFAULT_TYPES
    end

    def theme
      DEFAULT_THEME
    end
  end
end

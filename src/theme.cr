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

    property entry : Entry

    def initialize(entry)
      @entry = entry
    end

    def color
      types = FT.match do |r|
        r =~ @entry.type
      end
      theme.get_any types
    end

    def theme
      DEFAULT_THEME
    end
  end
end

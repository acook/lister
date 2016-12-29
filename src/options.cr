require "libmagic-crystal/magic"
require "./support/terminal"
require "./support/themer"

module Lister
  # the Options object is essentially an environment which gets passed around
  #   in lieu of globals or tons of extraneous arguments
  # this object stores the commandline options and the interface to libmagic
  class Options

    DEFAULT_THEME = Themer.build do
      default style: :normal
      for "broken", bg: :red
      for "directory", style: :bold, fg: :black
      for "source", fg: :white
        for "shell", fg: :magenta
          #for "bash", fg: :green
          #for "zsh", fg: :blue
        for "script", fg: :white
          for "perl", style: :bold, fg: :yellow
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

    property recurse : Int8 = 1_i8
    property magic : Magic::Magic
    property terminal = Terminal.new
    property theme : Themer::Theme = DEFAULT_THEME

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

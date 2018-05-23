require "libmagic-crystal/magic"
require "./support/terminal"
require "./support/themer"

module Lister
  # the Options object is essentially an environment which gets passed around
  #   in lieu of globals or tons of extraneous arguments
  # this object stores the commandline options and the interface to libmagic
  class Options

    DEFAULT_THEME = Themer.build do
      default style: "normal"
      for "broken", bg16: "red"
      for "directory", style: "bold", fg16: "black"
      for "source", fg16: "white"
        for "shell", fg16: "magenta"
          #for "bash", fg: :green
          #for "zsh", fg: :blue
        for "script", fg16: "white"
          for "perl", style: "bold", fg16: "yellow"
          for "ruby", fg16: "red"
      for "program", fg16: "blue"
        # x86
        # arm
      for "unix", fg16: "yellow"
        # link
        # socket
      for "image", style: "bold", fg16: "magenta"
        # gif
        # jpeg
      for "compressed", style: "bold"
        for "doom", style: "bold", fg16: "green"
    end

    property show_hidden : Bool = false
    property show_type_names : Bool = false
    property show_mime_types : Bool = false
    property recurse : Int8 = 1_i8

    property magic : Magic::Magic
    property magic_mime : Magic::Magic
    property terminal = Terminal.new
    property theme : Themer::Theme = DEFAULT_THEME

    def initialize
      # the default flags set it to only return MIME types,
      #   which is an extremely limited subset of possible types
      #   the below line could be used instead, but
      #   the current flags also search compressed files
      @magic = Magic::Magic.new flags: Magic::LibMagic::Flags::COMPRESS.to_i
      @magic_mime = Magic::Magic.new flags: Magic::LibMagic::Flags::MIME.to_i
    end

    def recurse?
      @recurse > 0
    end
  end
end

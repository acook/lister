require "magic/magic"
require "./support/terminal"
require "./support/themer/themer"

module Lister
  # the Options object is essentially an environment which gets passed around
  #   in lieu of globals or tons of extraneous arguments
  # this object stores the commandline options and the interface to libmagic
  class Options

    DEFAULT_THEME = Themer.build do
      default style: "normal"

      for "sigil", style16: "bold", fg16: "white", fg: "#FFFFFF"

      for "broken",
        style: "crossed_out" , fg: "#FFFFFF", bg: "#FF0000",
        style16: "crossed_out", fg16: "white", bg16: "red"

      for "directory",
        style:    "none", fg: "#999999",
        style256: "none", fg256: "244",
        style16:  "bold", fg16: "black"

      for "document", style16: "italic"
      for "text", style16: "italic"

      for "source", fg16: "white"
        for "shell", fg: "#344D3F", fg16: "green"
          #for "bash", fg: "#344D3F"
          #for "zsh", fg16: "blue"
        for "script", fg16: "white"
          for "perl", style: "bold", fg16: "yellow"
          for "ruby", fg16: "red", fg: "#CC0000"
      for "program", fg16: "blue"
        for "x86_32", fg: "#0071c5"
        for "x86_64", fg: "#009A66"
        for "arm_32", fg: "#0091BD"
        for "arm_64", fg: "#333E48"
      for "special", fg16: "yellow"
        # link
        # socket
      for "image", style: "bold", fg16: "magenta"
        # gif
        # jpeg
      for "compressed", style16: "bold"
        #for "zip", fg: "#11699b"
        for "wad", style: "bold", fg: "#2A5225", style16: "bold", fg16: "green"
    end

    property show_hidden : Bool = false
    property show_type_names : Bool = false
    property show_mime_types : Bool = false
    property recurse : Int8 = 1_i8

    property magic : Magic::TypeChecker
    property magic_mime : Magic::TypeChecker
    property terminal = Terminal.new

    property palette : Int32 = Int32::MAX
    property theme : Themer::Theme = DEFAULT_THEME
    property full_line : Bool = false

    def initialize
      (@magic = Magic::TypeChecker.new).look_into_compressed_files
      (@magic_mime = Magic::TypeChecker.new).get_mime_type
    end

    def recurse?
      @recurse > 0
    end
  end
end

module FT
  alias TypeList = Array(String)
  alias TypeNest = Array(TypeList)
  alias TypeMap  = Hash(Symbol, Node)

  class Node
    property name   : Symbol
    property parent : Node | Nil
    property regex  : Regex | Nil

    def initialize(@name, @parent, @regex)
    end

    def list : TypeList
      parent = @parent
      this   = [name.to_s]
      if parent
        this + parent.list
      else
        this
      end
    end
  end

  class Builder
    property nodes : TypeMap = TypeMap.new
    property type : Node | Nil = nil

    def initialize(@type = nil)
    end

    def type(name, parent : Symbol | Node | Nil = nil, regex : Regex | Nil = nil) : Node
      type(name, regex, parent) {}
    end

    def type(name, regex : Regex | Nil = nil, parent : Symbol | Node | Nil = nil) : Node
      type(name, regex, parent) {}
    end

    def type(name, regex : Regex | Nil = nil, parent : Symbol | Node | Nil = nil) : Node
      if parent.is_a? Symbol
        parent = nodes[parent]
      else
        parent ||= @type
      end

      new_node = Node.new name, parent, regex

      sub_builder = self.class.new new_node

      with sub_builder yield

      nodes[name] = new_node
      nodes.merge! sub_builder.nodes
      new_node
    end

    def default(name) : Node
      nodes[:DEFAULT] = Node.new name, nil, nil
    end
  end

  def self.build : TypeMap
    Builder.new.tap do |b|
      with b yield
    end.nodes
  end

  def self.[](name) : Node
    DEFAULT_TYPES.fetch name, DEFAULT_TYPES[:DEFAULT]
  end

  def self.match(fallback = DEFAULT_TYPES[:DEFAULT].list) : TypeNest
    types = TypeNest.new
    DEFAULT_TYPES.map do |_, node|
      next if node.regex.nil?

      if yield node.regex
        types = [node.list] + types
      end
    end

    if types.empty?
      [fallback]
    else
      types.reduce(TypeNest.new) do |acc, t1|
        if types.any?{ |t2| t1 != t2 && t1.size == (t1 & t2).size }
          acc
        else
          acc = acc + [t1]
        end
      end
    end
  end

  def self.match(type) : TypeNest
    self.match { |r| r =~ type }
  end

  DEFAULT_TYPES = build do
    default :unknown

    # for sigils, not actually used but here for --list-types
    type :sigil
      type :/, :sigil #, /^\/$/
      type :*, :sigil #, /^\*$/
      type :"@", :sigil #, /^\@$/

    type :directory, nil, /directory/

    type :text
      type :ascii, :text, /ASCII/
      type :utf8, :text, /UTF-8/

    type :document
      type :pdf, :document, /PDF/

    type :data
      type :xml, :data, /XML/

    type :program, nil, /program|executable/
      type :win32,  :program, /MS Windows/i
      type :x86_32, :program, /executable.*(i386|Intel 80386)/i
      type :x86_64, :program, /executable.*(x86-64)/i
      type :arm_32, :program, /(32-bit).*executable.*(ARM)/i
      type :arm_64, :program, /(64-bit).*executable.*(ARM)/i

    type :source
      type :c,     :source, /c source/i
      type :shell, :source, /shell/i
        type :bash, :shell, /bash|Bourne/i
        type :zsh, :shell, /zsh/i
      type :script, :source
        type :perl, :script, /perl/i
        type :ruby, :script, /ruby/i
        type :python, :script, /python/i
        type :makefile, :script, /makefile/

    type :compressed, nil, /archive/
      type :wad, :compressed, /doom|PWAD/
      type :zip, :compressed, /Zip/

    type :library
      type :dll,    :library, /DLL/
      type :msvc,   :library, /MSVC/
      type :so,     :library, /shared object/
      type :ar,     :library, /ar archive/
      type :object, :library, /relocatable/

    type :resource
      type :font, :resource, /font/
        type :otf, :font, /OpenType font/
        type :ttf, :font, /TrueType font/

    type :special
      type :link, :special, /symbolic link|socket/
      type :named_pipe, :special, /^fifo \(named pipe\)/
      type :socket, :special
      type :sticky, :special, /sticky/
      type :chardev, :special, /character special/
      type :blockdev, :special, /block special/

    type :image
      type :gif, :image, /GIF/
      type :jpg, :image, /JPEG/
      type :png, :image, /PNG/

    type :audio
      type :soundfont, :audio, /SoundFont/
      type :wave, :audio, /RIFF|AIFF/
      type :vorbis, :audio, /Vorbis audio/
      type :mpeg, :audio, /^Audio.*MPEG/

    type :broken, nil, /broken|NOT FOUND|cannot open/
  end

end

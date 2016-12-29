module FT
  class Node
    property name   : Symbol
    property parent : Node | Nil
    property regex  : Regex | Nil

    def initialize(@name, @parent, @regex)
    end

    def list
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
    property nodes = Hash(Symbol, Node).new

    def type(name, parent : Symbol | Node | Nil, regex : Regex | Nil = nil)
      if parent.is_a? Symbol
        parent = nodes[parent]
      end

      nodes[name] = Node.new name, parent, regex
      nodes
    end

    def default(name)
      nodes[:DEFAULT] = Node.new name, nil, nil
      nodes
    end
  end

  def self.build
    d = Builder.new
    filetypes = with d yield
    filetypes
  end

  def self.[](name)
    DEFAULT_TYPES.fetch name, DEFAULT_TYPES[:DEFAULT]
  end

  def self.match
    DEFAULT_TYPES.map do |_, node|
      next if node.regex.nil?

      if yield node.regex
        return node.list
      end
    end

    DEFAULT_TYPES[:DEFAULT].list
  end

  DEFAULT_TYPES = build do
    default :unknown

    type :broken, nil, /broken|NOT FOUND|cannot open/
    type :directory, nil, /directory/

    type :source, nil
    type :shell, :source, /shell|SHELL/
    type :bash, :shell, /bash|Bourne/
    type :zsh, :shell, /zsh/
    type :script, :source
    type :perl, :script, /perl|Perl/
    type :ruby, :script, /ruby|Ruby/
    type :python, :script, /python/

    type :program, nil, /program/
    type :x86, :program, /x86|i386/
    type :arm, :program

    type :compressed, nil
    type :wad, :compressed, /doom|PWAD/
    type :zip, :compressed

    type :unix, nil
    type :link, :unix, /link|socket/
    type :socket, :unix

    type :image, nil
    type :gif, :image, /GIF/
    type :jpg, :image
  end

end

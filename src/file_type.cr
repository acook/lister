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
    property nodes = TypeMap.new

    def type(name, parent : Symbol | Node | Nil = nil, regex : Regex | Nil = nil) : Node
      if parent.is_a? Symbol
        parent = nodes[parent]
      end

      nodes[name] = Node.new name, parent, regex
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

  def self.match : TypeNest
    types = TypeNest.new
    DEFAULT_TYPES.map do |_, node|
      next if node.regex.nil?

      if yield node.regex
        types = [node.list] + types
      end
    end

    if types.empty?
      [DEFAULT_TYPES[:DEFAULT].list]
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

    type :broken, nil, /broken|NOT FOUND|cannot open/
    type :directory, nil, /directory/

    type :text, nil
    type :ascii, :text, /ASCII/
    type :utf8, :text, /UTF-8/

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

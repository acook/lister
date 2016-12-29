module FT
  class Node
    property parent : Node | Nil
    property name   : Symbol

    def initialize(@name, @parent)
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

    def type(name, parent : Symbol | Node | Nil)
      if parent.is_a? Symbol
        parent = nodes[parent]
      end

      nodes[name] = Node.new name, parent
      nodes
    end

    def default(name)
      nodes[:DEFAULT] = Node.new name, nil
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

  DEFAULT_TYPES = build do
    default :unknown

    type :broken, nil
    type :directory, nil

    type :source, nil
    type :shell, :source
    type :bash, :shell
    type :script, :source
    type :perl, :script
    type :ruby, :script
    type :python, :script

    type :program, nil
    type :x86, :program
    type :arm, :program

    type :compressed, nil
    type :wad, :compressed
    type :zip, :compressed

    type :unix, nil
    type :link, :unix
    type :socket, :unix

    type :image, nil
    type :gif, :image
    type :jpg, :image
  end
end

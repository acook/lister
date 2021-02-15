require "spec"
require "../src/file_type"

describe FT do
  it "gives filetypes" do
    FT::DEFAULT_TYPES[:bash].list.should eq %w{bash shell source}
  end

  describe FT::Builder do
    klass = FT::Builder

    it "lets you build filetype heirarchies with nested blocks" do
      subject = klass.new
      nodes = subject.nodes
      new_nodes = Array(FT::Node).new

      new_nodes << subject.type :foo do
        new_nodes << type :bar do
          new_nodes << type :baz, /baz/
        end
      end

      nodes.values.to_set.should eq new_nodes.to_set
      nodes[:foo].parent == nil
      nodes[:bar].parent == nodes[:foo]
      nodes[:baz].parent == nodes[:bar]
    end
  end
end

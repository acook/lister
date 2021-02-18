require "./spec_helper"
require "../src/entry"
require "../src/options"

def new_entry(path, options = Lister::Options.new)
  Lister::EntryFactory.new(options.engine).build path
end

describe Lister::EntryFactory do
  klass = Lister::EntryFactory

  describe "regression tests" do
    it "doesn't raise an error on broken symlinks" do
      nowhere = "/var/tmp/nowhere"
      nothere = "/hippopotamus/homunculi"
      system "ln -s #{nothere} #{nowhere} 2> /dev/null"

      e = new_entry(nowhere)
      e.fp.symlink?.should eq true
      e.type.should eq "broken symbolic link to #{nothere}"
    ensure
      system "rm #{nowhere}"
    end

    it "doesn't error when called on a subdirectory of a file" do
      e = new_entry "/dev/null/nowhere"
      e.type.should eq "(FILE NOT FOUND)"
    end
  end

  it "should recognize files" do
    e = new_entry "."
    e.fp.exists?.should eq true
    e.type.should contain "directory ("
  end
end

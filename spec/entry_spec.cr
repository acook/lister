require "./spec_helper"
require "../src/entry"
require "../src/options"

def new_entry(path, options = Lister::Options.new)
  Lister::Entry.new(path, options)
end

describe Lister::Entry do
  klass = Lister::Entry

  describe "regression tests" do
    it "doesn't raise an error on broken symlinks" do
      nowhere = "/var/tmp/nowhere"
      nothere = "/hippopotamus/homunculi"
      system "ln -s #{nothere} #{nowhere} 2> /dev/null"

      e = new_entry(nowhere)
      e.type.should eq "broken symbolic link to #{nothere}"
    ensure
      system "rm #{nowhere}"
    end
  end
end

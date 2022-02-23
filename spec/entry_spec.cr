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

    pending "doesn't raise an error when access is denied to a directory" do
      # create a directory with permissions that will break this
      no_access_dir = "lister_test.tmp"
      system "mkdir #{no_access_dir}"
      system "chmod -x #{no_access_dir}"
      # attempt to traverse it
      e = new_entry(no_access_dir)
      e.type.should eq "asdkjgsdfkjgf"
    end
  end
end

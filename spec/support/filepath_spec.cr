require "../spec_helper"
require "../../src/support/filepath"

describe FilePath do
  klass = FilePath
  it "does stuff" do
    fp = klass.pwd
    fp.to_s.should eq "."
    fp.exists?.should eq true
    fp.symlink?.should eq false
    fp.device?.should eq false
  end
end

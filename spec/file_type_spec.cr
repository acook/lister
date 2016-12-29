require "spec"
require "../src/file_type"

describe FT do
  it "gives filetypes" do
    FT::DEFAULT_TYPES[:bash].list.should eq %w{bash shell source}
  end
end

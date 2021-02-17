require "./spec_helper"
require "../../src/support/pathname"

describe Pathname do
  klass = Pathname

  describe "regression tests" do
    it "doesn't error when called on a subdirectory of a file" do
      klass.new "/dev/null/nowhere"
    end
  end
end

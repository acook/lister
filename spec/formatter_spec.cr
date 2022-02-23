require "./spec_helper"
require "../src/entry"
require "../src/options"

def new_formatter(path, options = Lister::Options.new)
  Lister::Formatter.new(path, options)
end

describe Lister::Formatter do
  klass = Lister::Formatter

  describe "#line" do
    pending "should not attempt to insert color codes past the end of the line" do
      long_filename = "asdfghjklqwertyuiopzxcvbnm"
      opts = Lister::Options.new
      # stub out terminal width somehow
      opts.terminal.width
      # make entry
      entry = Entry.new long_filename, opts
      formatter = new_formatter(long_filename, opts)
      formatter.line(entry, entry.name.size, 0)
      # should generate a filename much lonager than the line, which before the fix would error out
      # like "index out of range" for String#insert
    end
  end
end

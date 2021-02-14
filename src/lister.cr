require "./version"
require "./cli"

begin
  Lister::CLI.new.set_options(ENV, ARGV).run
ensure
  # make sure we don't make a mess of the terminal colors
  print "\e[0m"
end

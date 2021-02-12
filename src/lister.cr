require "./version"
require "./cli"

begin
  Lister::CLI.new.set_options(ENV, ARGV).run
ensure
  # make sure we don't make a mess of the terminal colors
  print "\e[0m"
  # HACK: The following is a result of a major bug in Crystal
  # https://github.com/crystal-lang/crystal/issues/2065
  STDOUT.blocking = true
  STDERR.blocking = true
end

require "./cli"

Lister::CLI.new.parse_args(ARGV).run

require "docopt"
require "./libctags"

# Define the usage pattern for docopt
HELP = <<-DOCOPT
Usage:
    readtags [-i][-n] <FILE> <NAME>...
    readtags --version
    readtags --help

Options:
    -h --help     Show this screen.
    -v --version  Show version.
DOCOPT

options = Docopt.docopt(HELP, ARGV)

# Handle version manually
if options["--version"]
  puts "readtags #{Ctags::VERSION}"
  exit 0
end

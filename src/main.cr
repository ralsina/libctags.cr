require "docopt"
require "./libctags"

# Define the usage pattern for docopt
HELP = <<-DOCOPT
readtags: search for one or more tags in a ctags file

Usage:
    readtags [-i][-n] <FILE> <NAME>...
    readtags --version
    readtags --help

Options:
    -i            Case-insensitive search
    -n            Show line numbers
    -h --help     Show this screen.
    -v --version  Show version.
DOCOPT

options = Docopt.docopt(HELP, ARGV)

# Handle version manually
if options["--version"]
  puts "readtags #{Ctags::VERSION}"
  exit 0
end

require "docopt"
require "./libctags"

# Define the usage pattern for docopt
HELP = <<-DOCOPT
readtags: search for one or more tags in a ctags file

If FILE is not specified it defaults to "tags"

Usage:
    readtags [-i][-n] [FILE] <NAME>...
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

# Handle help manually
if options["--help"]
    puts HELP
    exit 0
  end
  
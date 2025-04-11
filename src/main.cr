require "docopt"
require "./libctags"

# Define the usage pattern for docopt
HELP = <<-DOCOPT
Usage:
    readtags [options]

Options:
    -h --help     Show this screen.
    -v --version  Show version.
DOCOPT

options = Docopt.docopt(HELP, ARGV)

# Handle version manually
if options["--version"]
  puts "tartrazine #{Ctags::VERSION}"
  exit 0
end

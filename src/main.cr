require "docopt"
require "./libctags"

# Define the usage pattern for docopt
HELP = <<-DOCOPT
readtags: search for one or more tags in a ctags file

If FILE is not specified it defaults to "tags"

Usage:
    readtags [-i][-n] [-f <FILE>] <NAME>...
    readtags --version
    readtags --help

Options:
    -f            Tags file [default: tags]
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

# Get the file path from options and open it
file_path = options["<FILE>"].to_s
file = Ctags::File.new(file_path)

# Get the tags we want to find, case-insensitive if specified
tags = options["<NAME>"].as(Array(String))
case_insensitive = options["-i"]

# For each tag, call file.find_entry
tags.each do |tag|
  entry = file.find_entry(tag, case_insensitive ? Ctags::TAG_IGNORECASE : 0)
  if entry
    # Print the entry details
    puts "Found tag: #{entry.name}"
    puts "File: #{entry.file}"
    puts "Line: #{entry.line_number}" if options["-n"]
    puts "-------------------"
  else
    puts "Tag not found: #{tag}"
  end
end

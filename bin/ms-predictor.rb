ARGV.each do |file|
  raise StandardError if File.extname(file) != '.fasta'
  # Do stuff

end

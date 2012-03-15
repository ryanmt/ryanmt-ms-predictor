#!/usr/bin/env ruby 
require 'ryanmt-ms-predictor'
# Initiation stuff
write = Ryan::MS::Predictor::Outputter.new
dig = Ryan::MS::Predictor::Digestor.new('trypsin')
frag = Ryan::MS::Predictor::Fragmenter.new()
iso = Ryan::MS::Predictor::Isotoper.new()
# runtime stuff
ARGV.each do |file|
  raise StandardError if File.extname(file) != '.fasta'
  entries = {}
  ::MS::Fasta.open(file) do |fasta| 
    fasta.each {|entry| entries[entry.header] = entry.sequence }
  end
  entries.each do |header,sequence|
    pep_seqs = dig.digest(sequence, :minimum_length => 6)
    pep_seqs.each do |pep_seq|
      ms2_masses = frag.fragment(pep_seq)
      ms2_intensities = ms2_masses.map { rand(100) }
      ms1 = iso.generate_spectra(pep_seq).transpose
      write.add_ms1(pep_seq, ms1)
      write.add_ms2(pep_seq, [iso.monoisotopic_mass, 1, 100], [ms2_masses, ms2_intensities])
    end
  end
  outfile = File.basename(file).gsub(File.extname(file), '_predicted.mzML')
  write.output( outfile )
end # ARGV

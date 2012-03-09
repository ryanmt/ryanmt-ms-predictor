require 'ms/fasta'
require 'ms/mzml'
require_relative "digestor"
require_relative "fragmenter"
require_relative "isotoper"
require 'fileutils'
start_time = Time.now.to_i
module Ryan
  module MS
    module Predictor
      class Outputter
        def initialize
          @specs =[]
          @@rt = 0
          @@num = 1
        end
        def add_ms1(sequence_text, mzs_intensities)
          spec1 = ::MS::Mzml::Spectrum.new("scan=#{@@num}", params: ['MS:1000128', ['MS:1000511', 1]]) do |spec|
            spec.data_arrays = mzs_intensities
            spec.scan_list = ::MS::Mzml::ScanList.new do |s1|
              scan = ::MS::Mzml::Scan.new do |scan|
                scan.describe! ['MS:1000002', sequence_text]
                scan.describe! ['MS:1000016', @@rt, 'UO:0000010']
              end
              s1 << scan
            end
          end
          @specs << spec1
          @@num += 1
          @@rt += 1
        end
        def add_ms2(sequence_text, precursor_arr, mzs_intensities)
          precursor_mass, precursor_charge, precursor_intensity = *precursor_arr
          spec_params = ['MS:1000127', ['MS:1000511', 2], "MS:1000580"]
          spec2 = ::MS::Mzml::Spectrum.new("scan=#{@@num}", params: spec_params) do |spec|
            spec.data_arrays = mzs_intensities
            spec.scan_list = ::MS::Mzml::ScanList.new do |s1|
              scan = ::MS::Mzml::Scan.new do |scan|
                scan.describe! ['MS:1000002', sequence_text]
                scan.describe! ['MS:1000016', @@rt, 'UO:0000010']
              end
              s1 << scan
            end
            precursor = ::MS::Mzml::Precursor.new( spec2 )
            si = ::MS::Mzml::SelectedIon.new
            # m/z
            si.describe! ["MS:1000744", precursor_mass]
            # z
            si.describe! ["MS:1000041", precursor_charge]
            # intensity
            si.describe! ["MS:1000042", precursor_intensity]
            precursor.selected_ions = [si]
            spec.precursors = [precursor]
          end
          @specs << spec2
          @@num += 1
          @@rt += 1
        end
        def output(outfile_name, description_text = nil)
          # writes file
          mzml = ::MS::Mzml.new do |mzml|
            mzml.id = 'Ryan::MS::Predictor_output'
            mzml.cvs = ::MS::Mzml::CV::DEFAULT_CVS
            mzml.file_description = ::MS::Mzml::FileDescription.new do |fd|
              fd.file_content = ::MS::Mzml::FileContent.new
              fd.source_files << ::MS::Mzml::SourceFile.new
            end
            default_instrument_config = ::MS::Mzml::InstrumentConfiguration.new("IC",[], params: ['MS:1000031'])
            mzml.instrument_configurations << default_instrument_config
            software = ::MS::Mzml::Software.new
            mzml.software_list << software
            default_data_processing = ::MS::Mzml::DataProcessing.new("did_nothing")
            mzml.data_processing_list << default_data_processing
            mzml.run = ::MS::Mzml::Run.new(description_text, default_instrument_config) do |run|
              spectrum_list = ::MS::Mzml::SpectrumList.new(default_data_processing)
              spectrum_list.push(*@specs)
              run.spectrum_list = spectrum_list
            end
          end
          mzml.to_xml outfile_name
        end # output_default
      end # class MzML
    end
  end
end

if __FILE__ == $0
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
    write.output( file )
  end # ARGV
end



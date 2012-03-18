require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
BSA_REV_MATCH = Regexp.new("ALATQTSVVLKPGEVAFCAEKDDAACCKDVFAV")
BSA_FWD_MATCH = Regexp.new("ALATQTSVVLKPGEVAFCAEKDDAACCKDVFAV".reverse)
TEST_FASTAS = ['bsa.fasta', 'human_xueyuan.fasta']
describe Ryan::MS::Search::Decoy do 
  before :each do 
    @decoy = Ryan::MS::Search::Decoy
    @cmdline = Ryan::MS::Search::Decoy::Cmdline
    @opts = {concatenate: false, type: :reverse, :prefix => 'DECOY_'}
  end
  after :each do 
    FileUtils.rm @file_out
  end
  describe 'decoy-ifies a database' do 
    it 'reverses' do 
      File.exist?('bsa_reversed.decoy.fasta').should == false
      @file_out = @decoy.new(type: :reverse).generate(TEST_FASTAS.first)
      File.exist?('bsa_reversed.decoy.fasta').should == true
    end
    it 'randomizes' do 
      File.exist?('bsa_shuffled.decoy.fasta').should == false
      @file_out = @decoy.new(type: :randomize).generate(TEST_FASTAS.first)
      File.exist?('bsa_shuffled.decoy.fasta').should == true
    end
    it 'concatenates' do 
      File.exist?('bsa_concatenated_shuffled.decoy.fasta').should == false
      @file_out = @decoy.new(type: :randomize, concatenate: true).generate(TEST_FASTAS.first)
      File.exist?(@file_out).should == true
    end
    it 'defaults to a separate and reversed database' do 
      File.exist?('bsa_reversed.decoy.fasta').should == false
      @file_out = @decoy.new.generate(TEST_FASTAS.first)
      File.exist?('bsa_reversed.decoy.fasta').should == true
    end
  end
  it 'changes prefixes on command' do 
    arr =[]
    arr << @cmdline.run(%w|-c --shuffle --prefix HELLO_ bsa.fasta|).last
    File.exist?('bsa_concatenated_shuffled.decoy.fasta').should == true
    arr << @cmdline.run(%w|--shuffle --prefix HELLO_ bsa.fasta|).last
    File.exist?('bsa_shuffled.decoy.fasta').should == true
    arr << @cmdline.run(%w| bsa.fasta|).last
    File.exist?('bsa_reversed.decoy.fasta').should == true
    arr << @cmdline.run(%w|-c --prefix HELLO_ bsa.fasta|).last
    File.exist?('bsa_concatenated_reversed.decoy.fasta').should == true
    @file_out = arr.shift
    arr.each {|a| FileUtils.rm a }
  end
  describe 'output is correct' do 
    it 'for BSA default' do 
      @file_out = @decoy.new.generate(TEST_FASTAS.first)
      lines = File.open(@file_out, 'r').readlines
      lines.select{|a| a =~ BSA_REV_MATCH }.empty?.should == false
      lines.select{|a| a =~ BSA_FWD_MATCH }.empty?.should == true
    end
    it 'for BSA shuffle' do 
      @file_out = @decoy.new(:type => :randomize).generate(TEST_FASTAS.first)
      lines = File.open(@file_out, 'r').readlines
      lines.select{|a| a =~ BSA_FWD_MATCH }.empty?.should == true
    end
    it 'for prefix change' do 
      prefix = "TEST_THIS_"
      @file_out = @decoy.new(prefix: prefix).generate(TEST_FASTAS.first)
      lines = File.open(@file_out, 'r').readlines
      lines.select{|a| a =~ BSA_REV_MATCH }.empty?.should == false
      lines.select{|a| a =~ BSA_FWD_MATCH }.empty?.should == true
      lines.select{|a| a =~ Regexp.new(prefix) }.empty?.should == false
    end
  end
end


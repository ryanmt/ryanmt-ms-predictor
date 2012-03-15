$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'bundler/setup'
Bundler.require(:development)
Dir.glob(File.join(File.dirname(__FILE__), '..', 'lib', '**', '*.rb')).map{|f| require f}
# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
TESTFILES = File.join( 'spec', 'tfiles')
RSpec.configure do |config|
 
end

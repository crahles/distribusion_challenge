require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :development)

Dir[File.join(__dir__, 'lib', '**', '*.rb')].each { |file| require file }

Challenge.new

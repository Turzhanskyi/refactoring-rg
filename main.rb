$LOAD_PATH << File.expand_path('./bank_rg', __dir__)

require 'bundler/setup'
require 'bank_rg'

Console.new.call

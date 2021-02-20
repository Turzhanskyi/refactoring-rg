#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path('./lib', __dir__)

require 'bundler/setup'
require 'bank_rg'

BankRg::Console.call

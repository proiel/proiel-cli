#!/usr/bin/env ruby
#
# Word form occurrence extraction
#
require 'colorize'
require 'proiel'

if ARGV.length < 1
  STDERR.puts "Usage: #{$0} treebank-files(s)"

  exit 1
end

tb = PROIEL::Treebank.new
tb.load_from_xml(ARGV)

form_index = {}

tb.sources.each do |source|
  source.tokens.each do |token|
    unless token.form.nil?
      form_index[token.form] ||= []
      form_index[token.form] << [source.id, token.id].join(':')
    end
  end
end

form_index.sort_by(&:first).each do |form, ids|
  puts "#{form}: #{ids.join(', ')}"
end

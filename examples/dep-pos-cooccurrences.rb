#!/usr/bin/env ruby
require 'proiel'
require 'colorize'
require 'terminal-table'

if ARGV.length < 1
  STDERR.puts "Usage: #{$0} treebank-files(s)"
  exit 1
end

tb = PROIEL::Treebank.new
tb.load_from_xml(ARGV)

# Present by POS
relations = tb.annotation.relation_tags.keys

c = {}
tb.sources.each do |s|
  s.tokens.each do |t|
    next if t.pos.nil? or t.relation.nil?

    c[t.pos] ||= {}
    c[t.pos][t.relation] ||= 0
    c[t.pos][t.relation] += 1
  end
end

rows = []
c.sort_by(&:first).each do |pos, d|
  total = d.inject(0) { |a, (k, v)| a + v }

  rows << [pos] + relations.map do |r|
    n = d[r ? r.to_s : nil]

    if n and n < total * 0.001
      n.to_s.red
    elsif n and n > total * 0.999
      n.to_s.green
    else
      n
    end
  end
end

table = Terminal::Table.new headings: ['Part of speech'] + relations, rows: rows
puts table
puts "(red = relation occurs for less than 0.1% of tokens with this POS; green = relation occurs for more than 99.9% of tokens with this POS)"
puts

# Present by relation
poses = tb.annotation.part_of_speech_tags.keys

c = {}

tb.sources.each do |s|
  s.tokens.each do |t|
    next if t.pos.nil? or t.relation.nil?

    c[t.relation] ||= {}
    c[t.relation][t.pos] ||= 0
    c[t.relation][t.pos] += 1
  end
end

rows = []
c.sort_by(&:first).each do |relation, d|
  total = d.inject(0) { |a, (k, v)| a + v }

  rows << [relation] + poses.map do |r|
    n = d[r ? r.to_s : nil]

    if n and n < total * 0.001
      n.to_s.red
    elsif n and n > total * 0.999
      n.to_s.green
    else
      n
    end
  end
end

table = Terminal::Table.new headings: ['Relation'] + poses, rows: rows
puts table
puts "(red = POS occurs for less than 0.1% of tokens with this relation; green = POS occurs for more than 99.9% of tokens with this relation)"

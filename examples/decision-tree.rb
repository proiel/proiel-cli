#!/usr/bin/env ruby
#
# Train a decision tree on the (head_relation, head_pos, head_lemma,
# child_relation, child_pos, child_lemma) and then predict the child_relation
# of an unknown child.
#
require 'colorize'
require 'decisiontree'
require 'proiel'

if ARGV.length < 1
  STDERR.puts "Usage: #{$0} treebank-files(s)"
  exit 1
end

tb = PROIEL::Treebank.new
tb.load_from_xml(ARGV)

tokens = {}

tb.sources.each do |source|
  source.tokens.each do |token|
    tokens[token.id.to_i] = [token.relation, token.part_of_speech, token.lemma, token.head_id]
  end
end

training_data = tokens.map do |_, (child_relation, child_pos, child_lemma, head_id)|
    if head_id
      head = tokens[head_id.to_i]
      head_relation, head_pos, head_lemma, _ = *head

      [head_pos || '', head_lemma || '', head_relation, child_pos || '', child_lemma || '', child_relation]
    end
  end.compact

attributes = %w(head_pos head_lemma head_relation child_pos child_lemma)
dr = DecisionTree::ID3Tree.new(attributes, training_data, 'pred', :discrete)
dr.train
dr.save_to_file("dr.marshal")

p dr.predict(["Ne", "Gallia", "sub", "Px", "omnis"])

#!/usr/bin/env ruby
#
# Does the dependency relation suffice to disambiguate ambiguous morphology?
#
require 'colorize'
require 'proiel'

if ARGV.length < 1
  STDERR.puts "Usage: #{$0} treebank-files(s)"

  exit 1
end

tb = PROIEL::Treebank.new
tb.load_from_xml(ARGV)

# Harvest morphology
form_hash = {}

tb.sources.reject { |source| source.language != language_tag }.each do |source|
  source.tokens.each do |token|
    next unless token.form and token.pos and token.morphology and token.relation

    # TODO: problem with using token.form is that sentence-initial words are sometimes capitalised
    relation_hash = (form_hash[token.form] ||= {})
    pos_hash = (relation_hash[token.relation] ||= {})
    morphology_hash = (pos_hash[token.pos] ||= {})
    morphology_hash[token.morphology] ||= 0
    morphology_hash[token.morphology] += 1
  end
end

# Calculate by unique forms first
unique_pos = 0
relation_predicts_pos = 0
relation_does_not_predict_pos = 0

unique_morphology = 0
relation_predicts_morphology = 0
relation_does_not_predict_morphology = 0

form_hash.each do |form, h|
  number_of_poses = 0
  number_of_morphologies = 0

  h.each do |_, i|
    i.each do |_, j|
      number_of_poses += 1
      j.each do |_, k|
        number_of_morphologies += 1
      end
    end
  end

  if number_of_poses == 1
    unique_pos += 1
  elsif h.all? { |_, i| i.keys.count == 1 }
    relation_predicts_pos += 1
  else
    relation_does_not_predict_pos += 1
  end

  if number_of_morphologies == 1
    unique_morphology += 1
  elsif h.all? { |_, i| i.all? { |_, j| j.keys.count == 1 } }
    relation_predicts_morphology += 1
  else
    relation_does_not_predict_morphology += 1
  end
end

puts "By unique forms (types)"
puts "======================="
puts "Forms with a unique POS:                               #{unique_pos}"
puts "Forms whose relation predicts its POS:                 #{relation_predicts_pos}"
puts "Forms whose relation does not predict its POS:         #{relation_does_not_predict_pos}"

puts "Forms with a unique morphology:                        #{unique_morphology}"
puts "Forms whose relation predicts its morphology:          #{relation_predicts_morphology}"
puts "Forms whose relation does not predict its morphology:  #{relation_does_not_predict_morphology}"

# Calculate by actual number of occurrences
unique_pos = 0
relation_predicts_pos = 0
relation_does_not_predict_pos = 0

unique_morphology = 0
relation_predicts_morphology = 0
relation_does_not_predict_morphology = 0

form_hash.each do |form, h|
  n = 0
  number_of_poses = 0
  number_of_morphologies = 0

  h.each do |_, i|
    i.each do |_, j|
      number_of_poses += 1
      j.each do |_, k|
        number_of_morphologies += 1
        n += k
      end
    end
  end

  if number_of_poses == 1
    unique_pos += n
  elsif h.all? { |_, i| i.keys.count == 1 }
    relation_predicts_pos += n
  else
    relation_does_not_predict_pos += n
  end

  if number_of_morphologies == 1
    unique_morphology += n
  elsif h.all? { |_, i| i.all? { |_, j| j.keys.count == 1 } }
    relation_predicts_morphology += n
  else
    relation_does_not_predict_morphology += n
  end
end

puts
puts "By occurrences of forms (tokens)"
puts "================================"
puts "Forms with a unique POS:                               #{unique_pos}"
puts "Forms whose relation predicts its POS:                 #{relation_predicts_pos}"
puts "Forms whose relation does not predict its POS:         #{relation_does_not_predict_pos}"

puts "Forms with a unique morphology:                        #{unique_morphology}"
puts "Forms whose relation predicts its morphology:          #{relation_predicts_morphology}"
puts "Forms whose relation does not predict its morphology:  #{relation_does_not_predict_morphology}"

exit 0

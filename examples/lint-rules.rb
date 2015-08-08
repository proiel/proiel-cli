#!/usr/bin/env ruby
#
# Very simple testing of implicational feature rules. Example rules only
# apply to Latin.
#
require 'colorize'
require 'proiel'

VIOLATIONS = {}

def report_violation(token, message)
  VIOLATIONS[message] ||= []
  VIOLATIONS[message] << token
end

def test_token(token, rules, dependent_rules)
  rules.each do |match_features, test_alternatives|
    f = token.features + ["\"#{token.form}\""]

    if (match_features - f).empty?
      unless test_alternatives.any? { |test_alternative| token.features.include?(test_alternative) }
        report_violation(token, "#{match_features.join(' ')}")
      end
    end
  end

  dependent_rules.each do |match_features, test_alternatives|
    f = token.features + ["\"#{token.form}\""]

    if (match_features - f).empty?
      t = token.children.all? do |dependent|
          test_alternatives.any? { |test_alternative| dependent.features.include?(test_alternative) }
        end

      unless t
        report_violation(token, "#{match_features.join(' ')} → dependents()")
      end
    end
  end
end

def load_rules
  rules = {}
  dependent_rules = {}

  DATA.each do |rule|
    rule.chomp!
    rule.sub!(/\s*#.*$/, '')

    next if rule.empty?

    match_features, test = rule.split(/\s*→\s*/)
    match_features = match_features.split(/\s+/)

    if test[/\s*dependents\(([^)]*)\)\s*/]
      dependent_rules[match_features] ||= []
      dependent_rules[match_features] << $1
      test.sub!(/\s*dependents\([^)]*\)\s*/, '')
    end

    if test != ''
      rules[match_features] ||= []
      rules[match_features] << test
    end
  end

  [rules, dependent_rules]
end

if ARGV.length < 1
  STDERR.puts "Usage: #{$0} treebank-files(s)"
  exit 1
end

tb = PROIEL::Treebank.new
tb.load_from_xml(ARGV)

rules, dependent_rules = load_rules

tb.sources.each do |source|
  source.sentences.each do |sentence|
    if sentence.status == 'reviewed'
      sentence.tokens.each do |token|
        test_token(token, rules, dependent_rules)
      end
    end
  end
end

base_url = 'http://foni.uio.no:3000'

puts "<h1>PROIEL lint report</h1>"

VIOLATIONS.each do |rule, tokens|
  puts "<h2>#{rule}</h2><ul>"
  tokens.each do |token|
    puts "<li>Token <a href='#{base_url}/tokens/#{token.id}'>#{token.id}</a> in sentence <a href='#{base_url}/sentences/#{token.sentence.id}'>#{token.sentence.id}</a></li>"
  end
  puts "</ul>"
end

__END__

# Gerundives
gdv nom → xobj    # modal gerundive heading a main clause

gdv acc → comp    # modal gerundive heading an AcI, or in the _curo faciendum_ type
gdv acc → xobj    # modal gerundive heading an AcI with an overt auxiliary
gdv acc → obl     # as argument of a preposition
gdv acc → xadv    # in the _do librum legendum_ type

gdv gen → atr     # in the _tempus dicendi_ type
gdv gen → narg    # in the _facultas dicendi_ type

gdv abl → obl     # as argument of a preposition
gdv abl → abl     # in circumstantial adjuncts of various types

# Gerunds
ger nom → 0       # invalid case for a gerundive

ger acc → obl     # as argument of a preposition

ger gen → atr     # in the _tempus dicendi_ type
ger gen → narg    # in the _facultas dicendi_ type

ger abl → obl     # as argument of a preposition
ger abl → abl     # in circumstantial adjuncts of various types

# Reflexive pronouns
persrefl nom → 0

persrefl acc → sub
persrefl acc → obj
persrefl acc → obl

persrefl dat → obl
persrefl dat → adv
persrefl dat → ag

persrefl abl → obl
persrefl abl → sub

persrefl "se" → acc
persrefl "se" → abl

persrefl "sese" → acc
persrefl "sese" → abl

persrefl "sibi" → dat

# Personal pronouns
perspron nom → sub

perspron acc → sub
perspron acc → obj
perspron acc → obl

perspron dat → obl
perspron dat → adv
perspron dat → ag

perspron abl → obl
perspron abl → sub

# The dependent of the complementisers _ut_ and _ne_ should be a PRED or an AUX
subj "ut" → dependents(pred)   # the standard case, a predicate heading a clause
subj "ut" → dependents(aux)    # some particle-like material dependent on the complementiser

subj "ne" → dependents(pred)
subj "ne" → dependents(aux)

# Particles and adverbs
"iam" → adverb adv
"iam" → adverb aux # possibly

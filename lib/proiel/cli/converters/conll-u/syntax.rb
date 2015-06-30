module PROIEL
  module Converter
    RELATION_MAPPING = {
      "adnom" => "dep",
      "adv" =>  [["advcl", lambda(&:clausal?) ],
                 ["advmod", lambda(&:adverb?) ],
                 ["nmod", lambda(&:nominal?) ],
                ],
      "ag" => "nmod:agent", 
      "apos" => [["name", lambda { |x| x.proper_noun? and x.head and x.head.proper_noun? } ],
                 ["appos", lambda { |x| x.nominal? and x.head and x.head.nominal? } ],
                 ["acl:relcl", lambda { |x| x.clausal? and x.head and x.head.nominal? } ],
                ],
      "arg" => "dep",
      "atr" => [["nummod", lambda(&:cardinal?) ],
                ["nmod", lambda(&:nominal?) ],
                ["acl:relcl", lambda { |x| x.clausal? and x.head and x.head.nominal? } ],
                ["amod", lambda { |x| x.adjectival? and x.head and x.head.nominal? } ], #if an adjective under a noun
                ["det", lambda(&:determiner?) ],
               ],
      "aux" => [["det", lambda(&:determiner?) ],
                ["aux", lambda(&:clausal?) ],
                ["neg", lambda(&:negation?) ],
                ["discourse", lambda { |x| x.particle? or x.interjection? } ],
                ["advmod", lambda { |x| x.adjectival? or x.adverb? } ], # or subjunction (? why did I write this?)
                ["cc", lambda(&:conjunction?) ],
                ["foreign", lambda(&:foreign?) ],
                # We need some more distinctions to get Gothic and Armenian. Introduce language in the treebank? (Read from xml)
                ["mark", lambda { |x| ['Pk', 'R-'].include? x.part_of_speech  } ], #reflexive as valency reducer, 'R-' as infinitive marker in Gothic
                ['amod', lambda { |x| x.preposition? } ], # Armenian DOM
                ['mwe', lambda { |x| ['Px', 'Pr'].include? x.part_of_speech } ], # NB there are a lot of bogus annotations with 'Px'
                
                # MISANNOTATION  IF A NOUN or a 'Pi' or a 'Pp' or a 'Ps'
               ],
      "comp" => [['csubjpass', lambda { |x| x.head and x.head.passive? } ],
                 ['csubj', lambda { |x| x.head and x.head.copula? } ],
                 ['ccomp', lambda { |x| true } ],
                ],
      "expl" => "expl",
      "narg" => [['acl', lambda(&:clausal?) ],
                 ['nmod', lambda(&:nominal?) ],
                ],
      "nonsub" => "dep",
      "obj" => "dobj",
      "obl" => [["advmod", lambda { |x| x.adverb? or x.preposition? } ], # though normally a preposition will be subordinate to its noun
                ["iobj", lambda(&:nominal?) ],# if nominal (NB check for presence of article!)
               ],
      "parpred" => "parataxis",
      "part" => "nmod",
      "per" => "dep",
      "pid" => ["ERROR", lambda { |x| raise "Remaining pid edge!" } ],
      "pred" => [["root", lambda(&:root?) ],
                 ["ERROR", lambda { |x| raise "#{x.to_n} (head_id #{x.head_id}) is not a root!" }],
                ],
      "rel" => "acl:relcl",
      "sub" => [["nsubjpass", lambda { |x| x.head and x.head.passive? } ],
                ["nsubj", lambda { |x| true }],
               ],
      "voc" => "vocative",
      "xadv" => [["advcl:contr", lambda(&:clausal?)],
                 ["advmod:contr", lambda { |x| true } ],
                ],
      "xobj" => "xcomp", # copula cases have already been taken care of
      "xsub" => "xsub",
    }
  end
end

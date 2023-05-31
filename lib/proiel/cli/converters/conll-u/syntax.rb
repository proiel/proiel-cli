module PROIEL
  module Converter
    class CoNLLU

      OBLIQUENESS_HIERARCHY = ['nsubj', 'obj', 'iobj', 'obl', 'advmod', 'csubj', 'xcomp', 'ccomp', 'advcl']
      REL_TO_POS = {
        'acl' => 'VERB',
        'advcl' => 'VERB',
        'advcl:cmp' => 'NOUN',
        'advmod' => 'ADV',
        'amod' => 'ADJ',
        'appos' => 'NOUN',
        'ccomp' => 'VERB',
        'conj' => 'X',
        'csubj' => 'VERB',
        'csubj:pass' => 'NOUN',
        'dep' => 'X',
        'det' => 'DET',
        'dislocated' => 'X',
        'fixed' => 'X',
        'flat:foreign' => 'X',
        'flat:name' => 'PROPN',
        'nmod' => 'NOUN',
        'nsubj' => 'NOUN',
        'nsubj:pass' => 'NOUN',
        'nsubj:outer' => 'NOUN',
        'nummod' => 'NUM',
        'obj' => 'NOUN',
        'obl' => 'NOUN',
        'obl:agent' => 'NOUN',
        'obl:arg' => 'NOUN',
        'orphan' => 'NOUN',
        'parataxis' => 'VERB',
        'root' => 'VERB',
        'vocative' => 'NOUN',
        'xcomp' => 'VERB'
       }

      RELATION_MAPPING = {
        'adnom' => 'dep',
        'adv' =>  [['advcl', lambda(&:clausal?) ],
                   ['advmod', lambda { |x| x.adverb? } ],
                   ['advmod', lambda(&:adjectival?) ], # adjective for adverb
                   ['obl', lambda { |x| x.nominal? or x.preposition? or x.has_preposition? } ],
                   ['advcl', lambda(&:subjunction?) ],
                   ['obl', lambda { |x| true } ],
                  ],
        'ag' => 'obl:agent', # add :agent" once defined
        'apos' => [['flat:name', lambda { |x| x.proper_noun? and x.head and x.head.proper_noun? } ],
                   ['acl', lambda { |x| x.clausal? and x.head and x.head.nominal? } ],  # add :relcl ?

                   ['appos', lambda { |x| (x.nominal? or x.adjectival?) and x.head and x.head.nominal? } ],
                   ['parataxis', lambda { |x| x.clausal? and x.head and x.head.clausal? } ],
                   # what to do about sentential appositions? attempt here to make them parataxis, but there are some legitimate nominal appos under root nominals, so overgenerates slightly
                   ['advcl', lambda(&:clausal?) ],
                   ['appos', lambda { |x| true } ],
                  ],
        'arg' => 'dep',
        'atr' => [['nummod', lambda(&:cardinal?) ],
                  ['det', lambda { |x| x.pronominal? and !x.clausal? and !(!x.genitive? and x.head and x.head.genitive?) } ], #TODO check
                  ['acl', lambda { |x| x.clausal? } ],  # add :relcl?
                  ['nmod', lambda(&:nominal?) ],
                  ['advmod', lambda { |x| x.head and !x.head.nominal? and x.head.clausal? } ],
                  ['amod', lambda { |x| true } ], #default
                 ],
        'aux' => [['det', lambda(&:determiner?) ],
                  ['fixed', lambda { |x| x.head and x.head.subjunction? } ],
                  ['fixed', lambda { |x| x.head and x.head.conjunction? } ],
                  ['fixed', lambda { |x| x.head and x.head.adverb? and x.relative? } ],
                  ['fixed', lambda { |x| x.head and x.head.pronominal? and x.verb? } ],
                  ['aux:pass', lambda { |x| x.clausal? and x.head.passive?  } ],
                  ['aux', lambda(&:clausal?) ], #v2 probably want the modal particle an to go here too in
                  ['advmod', lambda(&:negation?) ],
                  ['discourse', lambda { |x| x.particle? or x.interjection? } ],
                  ['advmod', lambda { |x| x.adjectival? or x.adverb? } ],
                  # make subjunctions in root sentences "mark"
                  ['mark', lambda { |x| x.subjunction? } ],
                  ['cc', lambda(&:conjunction?) ],
                  ['flat:foreign', lambda(&:foreign?) ],
                  # We need some more distinctions to get Gothic and Armenian. Introduce language in the treebank? (Read from xml)
                  ['mark', lambda { |x| ['R-'].include? x.part_of_speech  } ], #"R-" as infinitive marker in Gothic
                  ['expl:pv', lambda { |x| ['Pk' ].include? x.part_of_speech  } ], #reflexive as valency reducer
                  ['amod', lambda { |x| x.preposition? } ], # Armenian DOM
                  ['fixed', lambda { |x| ['Px', 'Pr'].include? x.part_of_speech } ], # NB there are a lot of bogus annotations with 'Px'

                  # MISANNOTATION  IF A NOUN or a 'Pi' or a 'Pp' or a 'Ps'
                 ],
        'comp' => [['csubj:pass', lambda { |x| x.head and x.head.passive? and !x.head.has_subject?} ],
                   ['csubj', lambda { |x| x.head and x.head.has_copula? and !x.head.has_subject?} ],
                   ['ccomp', lambda { |x| true } ],
                  ],
        'expl' => 'expl',
        'narg' => [['acl', lambda(&:clausal?) ],
                   ['nmod', lambda(&:nominal?) ],
                   ['nmod', lambda(&:adjectival?) ], # nominaliezed in this function
                   ['nmod', lambda { |x| true } ],
                  ],
        'nonsub' => 'dep',
        'obj' => 'obj',
        'obl' => [# normally a preposition will be subordinate to its noun, this captures adverbial use of prepositions
                  ['advmod', lambda { |x| x.adverb? } ],
                  ['obl', lambda { |x| x.has_preposition? or x.preposition? } ],
                  ['obl', lambda { |x| x.head and x.head.adverb? } ],
                  ['obl:arg', lambda { |x| (x.nominal? or x.adjectival?) and x.head and x.head.clausal? } ],# if nominal (NB check for presence of article!) TODO: should be 'obj' if the verb is monovalent (even by elision)
                  #['obl:arg', lambda(&:adjectival?) ], # OBL adjectives are nominalized
                  ['advcl', lambda(&:clausal?) ], # this seems to happen with ad libros legendos etc. but check closer!
                  ['obl', lambda { |x| true } ],
                 ],
        'parpred' => 'parataxis',
        'part' => 'nmod',
        'per' => 'dep',
        'pid' => ['ERROR', lambda { |x| raise 'Remaining pid edge!' } ],
        'pred' => [['root', lambda(&:root?) ],
                   ['ERROR', lambda { |x| raise '#{x.to_n} (head_id #{x.head_id}) is not a root!' }],
                  ],
        'rel' => 'acl', # add :relcl?
        'sub' => [['nsubj:pass', lambda { |x| x.head and x.head.passive? } ],
                  #['obl', lambda { |x| x.head and x.head.part_of_speech == 'Df' } ],
                  ['nsubj', lambda { |x| true }],
                 ],
        'voc' => [['discourse', lambda { |x| x.part_of_speech == 'I-' } ],
                  ['vocative', lambda { |x| true } ],
                 ],
        'xadv' => [['advcl', lambda(&:clausal?)], #add :contr ?
                   ['xcomp', lambda { |x| x.nominal? or x.pronominal? or x.cardinal?} ],
                   ['advcl', lambda(&:subjunction?)],
                   ['advmod', lambda { |x| true } ], # add :contr ?
                  ],
        'xobj' => 'xcomp', # copula cases have already been taken care of
        'xsub' => 'xsub',
      }
    end
  end
end

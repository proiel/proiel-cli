module PROIEL
  module Converter
    class CoNLLU
      COPULAR_LEMMATA = ['sum,V-,lat']
      DETERMINERS = ['S-', 'Pd', 'Px', 'Ps', 'Pt']
      NEGATION_LEMMATA = ['non,Df,lat', 'ne,Df,lat'] 
      PARTICLE_LEMMATA = [ 'at,Df,lat',
                           'atque,Df,lat',
                           'autem,Df,lat',
                           'certe,Df,lat',
                           'ergo,Df,lat',
                           'et,Df,lat',
                           'enim,Df,lat',
                           'etiam,Df,lat',
                           'igitur,Df,lat',
                           'immo,Df,lat',
                           'itaque,Df,lat',
                           'nam,Df,lat',
                           'nonne,Df,lat',
                           'nonne,Du,lat',
                           'quidem,Df,lat',
                           'quoque,Df,lat',
                           'sic,Df,lat',
                           'tamen,Df,lat',
                           'tum,Df,lat',
                           'tunc,Df,lat',
                           'vero,Df,lat' ]
      
      POS_MAP = 
        { 
          'A-' => ['ADJ'],
          'Df' => ['ADV'],
          'S-' => ['DET', "Definite=Def|PronType=Dem"], # (we only have definite articles)
          'Ma' => ['NUM'], 
          'Nb' => ['NOUN'],
          'C-' => ['CONJ'],
          'Pd' => ['DET'], 
          'F-' => ['X'],
          'Px' => ['PRON'], 
          'N-' => ['SCONJ'], #irrelevant for our purposes
          'I-' => ['INTJ'],
          'Du' => ['ADV', "PronType=Int"],
          'Pi' => ['PRON', "PronType=Int"],
          'Mo' => ['ADJ'], 
          'Pp' => ['PRON', "PronType=Prs"],
          'Pk' => ['PRON', "PronType=Prs|Reflex=Yes"],
          'Ps' => ['PRON', "PronType=Prs|Poss=Yes"],   ###  layered gender?
          'Pt' => ['PRON', "PronType=Prs|Poss=Yes|Reflex=Yes" ],   ###  layered gender? 
          'R-' => ['ADP'],
          'Ne' => ['PROPN'],
          'Py' => ['DET'], 
          'Pc' => ['PRON', "PronType=Rcp"],
          'Dq' => ['ADV', "PronType=Rel"],
          'Pr' => ['PRON', "PronType=Rel"],
          'G-' => ['SCONJ'],
          'V-' => ['VERB'],
          'X-' => ['X'] }
      
      MORPHOLOGY_MAP = {
        :person => {'1' => 'Person=1', 
                    '2' => 'Person=2', 
                    '3' => 'Person=3'  } , 
        :number => {'s' => 'Number=Sing', 
                    'd' => 'Number=Dual', 
                    'p' => 'Number=Plural'  } ,
        :tense  => {'p' => 'Tense=Present', 
                    'i' => 'Tense=Past|Aspect=Imp', 
                    'r' => 'Tense=Perfect', 
                    's' => 'Aspect=Resultative',
                    # tags Perf is not universal
                    'a' => 'Tense=Past|Aspect=Perf', 
                    'u' => 'Tense=Past', 
                    'l' => 'Tense=Pqp', 
                    'f' => 'Tense=Fut', 
                    # tag FutPerfect is not universal
                    't' => 'Tense=FutPerfect' },
        :mood =>   {'i' => 'VerbForm=Fin|Mood=Ind', 
                    's' => 'VerbForm=Fin|Mood=Sub', 
                    'm' => 'VerbForm=Fin|Mood=Imp', 
                    'o' => 'VerbForm=Fin|Mood=Opt', 
                    'n' => 'VerbForm=Inf', 
                    'p' => 'VerbForm=Part', 
                    'd' => 'VerbForm=Ger', 
                    # Gve (gerundive) is not universal
                    'g' => 'VerbForm=Gve', 
                    'u' => 'VerbForm=Sup', 
                    'e'=> 'VerbForm=Fin|Mood=Ind,Sub', 
                    'f'=> 'VerbForm=Fin|Mood=Ind,Imp', 
                    'h'=> 'VerbForm=Fin|Mood=Imp,Sub', 
                    't' => 'VerbForm=Fin' },
        :voice =>  {'a' => 'Voice=Act', 
                    # Med is not universal
                    'm' => 'Voice=Med', 
                    'p' => 'Voice=Pass', 
                    'e' => 'Voice=Pass,Med' },
        :gender => {'m' => 'Gender=Masc',
                    'f' => 'Gender=Fem',
                    'n' => 'Gender=Neut',
                    'p' => 'Gender=Masc,Fem',
                    'o' => 'Gender=Masc,Neut',
                    'r' => 'Gender=Neut,Fem' },
        :case =>   {'n' => 'Case=Nom', 
                    'a' => 'Case=Acc', 
                    # Obl(ique) is not universal
                    'o' => 'Case=Obl', 
                    'g' => 'Case=Gen', 
                    'c' => 'Case=Gen,Dat', 
                    'e' => 'Case=Acc,Dat', 
                    'd' => 'Case=Dat', 
                    'b' => 'Case=Abl', 
                    'i' => 'Case=Ins', 
                    'l' => 'Loc', 
                    'v' => 'Voc' },
        :degree => {'p' => 'Degree=Pos', 
                    'c' => 'Degree=Cmp', 
                    's' => 'Degree=Sup' },
        # The whole strength category is not universal
        :strength => {'w' => 'Strength=Weak',
                      's' => 'Strength=Strong'},
        :inflection => {},
      }
    end
  end
end
    

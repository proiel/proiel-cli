require 'proiel/cli/converters/conll-u/morphology'
require 'proiel/cli/converters/conll-u/syntax'

module PROIEL
  module Converter
    class CoNLLU
      class << self
        def process(tb, options = [])
          error_count = 0 
          sentence_count = 0
          tb.sources.each do |source|
            source.divs.each do |div|
              div.sentences.each do |sentence|
                sentence_count += 1
                n = Sentence.new sentence
                # Unlike other conversions, this one has to rely on
                # certain assumptions about correct linguistic
                # annotation in order to producea meaningful
                # representation in CoNLL-U
                begin
                  puts n.convert.to_conll
                  puts
                rescue => e
                  error_count += 1
                  STDERR.puts "Cannot convert #{sentence.id} (#{sentence.citation}): #{e}"
                end
              end
            end
          end
          STDERR.puts "#{error_count} sentences out of #{sentence_count} could not be converted"
        end
      end

      class Sentence

        attr_accessor :tokens

        # initializes a PROIEL::Convert::Sentence from PROIEL::PROIELXML::Sentence
        def initialize(sentence)

          id_to_number = Hash.new(0) #will return id 0 (i.e. root) for nil

          tk = sentence.tokens.reject { |t| t.empty_token_sort == 'P' }
          
          tk.map(&:id).each_with_index.each do |id, i|
            id_to_number[id] = i + 1
          end

          @tokens = tk.map do |t|
            Token.new(id_to_number[t.id],
                      id_to_number[t.head_id],
                      t.form.to_s.gsub(/[[:space:]]/, '.'),
                      t.lemma.to_s.gsub(/[[:space:]]/, '.'),
                      t.part_of_speech,
                      t.language,
                      t.morphology,
                      t.relation,
                      t.empty_token_sort,
                      t.slashes.map { |relation, target_id| [id_to_number[target_id], relation] },
                      t.citation_part,
                      self
                     )
          end
        end

        def convert
          restructure_graph!
          relabel_graph!
          map_part_of_speech!
          self
        end

        def find_token(identifier)
          @tokens.select { |t| t.id == identifier }.first
        end

        def remove_token!(token)
          @tokens.delete(token)
        end

        def to_s
          @tokens.map(&:to_s).join("\n")
        end

        def count_tokens
          roots.map(&:count_subgraph).inject(0, :+)
        end

        def roots
          @tokens.select { |t| t.head_id == 0 }.sort_by(&:id)
        end

        def to_graph
          roots.map(&:to_graph).join("\n")
        end

        def to_conll
          @tokens.map(&:to_conll).join("\n")
        end

        # TODO: this will leave several root nodes in many cases. For now, raise an error
        def prune_empty_rootnodes!
          unless (empty_roots = roots.select { |r| r.empty_token_sort == 'V' }).empty?
            empty_roots.each do |r|
              # promote the first dependent to root
              new_root = r.dependents.first
              new_root.head_id = 0
              new_root.relation = r.relation
              r.dependents.each { |d| d.head_id = new_root.id }
              remove_token! r
            end
            prune_empty_rootnodes!
          end
        end

        def demote_subjunctions!
          @tokens.select { |t| t.part_of_speech == 'G-' }.each(&:process_subjunction!)
        end

        def demote_parentheticals_and_vocatives!
          r, p = roots.partition { |n| !['voc', 'parpred'].include? n.relation }
          if p.any? and r.none?
            # promote the first vocative/parenthetical to head in case there's nothing else
            p.first.relation = 'pred'
            r, p = roots.partition { |n| !['voc', 'parpred'].include? n.relation }
          end
          raise "No unique root in this tree:\n#{to_graph}" if p.any? and !r.one?
          p.each { |x| x.head_id = r.first.id }
        end

        def relabel_graph!
          roots.each(&:relabel_graph!)
        end

        def map_part_of_speech!
          roots.each(&:map_part_of_speech!)
        end

        def restructure_graph!
          @tokens.delete_if { |n| n.empty_token_sort == 'P' }
          @tokens.select(&:preposition?).each(&:process_preposition!)
          roots.each(&:change_coordinations!)
          @tokens.select(&:copula?).each(&:process_copula!)
          prune_empty_rootnodes!
          # do ellipses from left to right for proper remnant treatment
          @tokens.select(&:ellipsis?).sort_by { |e| e.left_corner.id }.each(&:process_ellipsis!)
          demote_subjunctions!
          # DIRTY: remove the rest of the empty nodes by attaching them
          # to their grandmother with remnant. This is the best way to
          # do it given the current state of the UDEP scheme, but
          # revisions will come.
          roots.each(&:remove_empties!)
          demote_parentheticals_and_vocatives!
        end
      end

      class Token

        attr_accessor :head_id
        attr_accessor :upos
        attr_reader :relation
        attr_reader :part_of_speech
        attr_reader :id
        attr_reader :lemma
        attr_reader :language
        attr_reader :empty_token_sort
        attr_reader :form
        attr_reader :citation_part

        def initialize(id, head_id, form, lemma, part_of_speech, language, morphology, relation, empty_token_sort, slashes, citation_part, sentence)
          @id = id
          @head_id = head_id
          @form = form
          @lemma = lemma
          @part_of_speech = part_of_speech
          @language = language
          @morphology = morphology
          @relation = relation
          @empty_token_sort = empty_token_sort
          @slashes = slashes
          @sentence = sentence
          @features = (morphology ? map_morphology(morphology) : '' )
          @citation_part = "ref=" + (citation_part ? citation_part : "").gsub(/\s/, '_')
          @upos = nil
        end

        MORPHOLOGY_POSITIONAL_TAG_SEQUENCE = [
          :person, :number, :tense, :mood, :voice, :gender, :case,
          :degree, :strength, :inflection
        ]

        def map_morphology morph
        res = []
        for tag in 0..morph.length - 1
          res << MORPHOLOGY_MAP[MORPHOLOGY_POSITIONAL_TAG_SEQUENCE[tag]][morph[tag]]
        end
        res.compact.join('|')
        end

        # returns +true+ if the node is an adjective or an ordinal
        def adjectival?
          @part_of_speech == 'A-' or @part_of_speech == 'Mo'
        end

        def adverb?
          @part_of_speech =~ /\AD/
        end

        def cardinal?
          @part_of_speech == 'Ma'
        end

        # A node is clausal if it is a verb and not nominalized; or it has a copula dependent; or it has a subject (e.g. in an absolute constructino without a verb; or if it is the root (e.g. in a nominal clause)
        def clausal?
          (@part_of_speech == 'V-' and !nominalized?) or
            dependents.any?(&:copula?) or
            dependents.any? { |d| ['sub', 'nsubj', 'nsubjpass', 'csubj', 'csubjpass'].include? d.relation  } or
            root?
        end

        def conjunction?
          part_of_speech == 'C-' or @empty_token_sort == 'C'
        end

        def coordinated?
          head and head.conjunction? and head.relation == @relation
        end

        # Returns +true+ if the node has an xobj dependent and either 1)
        # the lemma is copular or 2) the node is empty and has no pid
        # slash or a pid slash to a node with a copular lemma
        def copula?
          @relation == 'cop' or 
          (COPULAR_LEMMATA.include?([lemma, part_of_speech, language].join(',')) or
           (@empty_token_sort == 'V' and (pid.nil? or pid.is_empty? or COPULAR_LEMMATA.include?([pid.lemma, pid.part_of_speech, pid.language].join(',')))) and
           dependents.any? { |d| d.relation == 'xobj' } )
        end

        def determiner?
          DETERMINERS.include? @part_of_speech
        end

        def ellipsis?
          @empty_token_sort == 'V'
        end

        def foreign?
          @part_of_speech == 'F-'
        end

        def has_content?
          @empty_token_sort.nil? or @empty_token_sort == ''
        end

        def interjection?
          @part_of_speech == 'I-'
        end

        def is_empty?
          !has_content?
        end

        def mediopassive?
          @morphology[4] =~/[mpe]/
        end

        def negation?
          NEGATION_LEMMATA.include?([lemma, part_of_speech, language].join(','))
        end

        def nominal?
          @part_of_speech =~ /\A[NPM]/ or nominalized?
        end

        def nominalized?
          dependents.any? do |d|
            d.determiner? and ['atr', 'aux', 'det'].include? d.relation
          end
        end

        def particle?
          @relation == 'aux' and PARTICLE_LEMMATA.include?([lemma, part_of_speech, language].join(','))
        end

        def passive?
          @morphology[4] == 'p'
        end

        def preposition?
          @part_of_speech == 'R-'
        end

        def proper_noun?
          @part_of_speech == 'Ne'
        end

        def root?
          @head_id == 0
        end

        def relation=(rel)
          if conjunction?
            dependents.select { |d| d.relation == @relation }.each do |c|
              c.relation = rel
            end
          end
          @relation = rel
        end

        def count_subgraph
          dependents.map(&:count_subgraph).inject(0, :+) + (is_empty? ? 0 : 1)
        end

        def subgraph_set
          [self] + dependents.map(&:subgraph_set).flatten
        end

        def left_corner
          ([self] + dependents).sort_by(&:id).first
        end

        def conj_head
          raise "Not a conjunct" unless @relation == 'conj'
          if head.relation == 'conj'
            head.conj_head
          else
            head
          end
        end

        def pid
          if pid = @slashes.select { |t, r| r == 'pid' }.first
            @sentence.tokens.select { |t| pid.first == t.id}.first
          else
            nil
          end
        end

        def format_features(features)
          if features == ''
            '_'
          else
            features.split("|").sort.join("|")
          end
        end
        
        def to_conll
          [@id, 
           @form, 
           @lemma, 
           @upos, 
           @part_of_speech, 
           format_features(@features), 
           @head_id, 
           (@head_id == 0 ? 'root' : @relation), # override non-root relations on root until we've found out how to handle unembedded reports etc
           '_', # slashes here
           @citation_part].join("\t")
        end

        def to_s
          [@id, @form, @head_id, @relation].join("\t")
        end

        def to_n
          [@relation, @id, (@form || @empty_token_sort), (@upos || @part_of_speech) ].join('-')
        end

        def to_graph(indents = 0)
          ([("\t" * indents) + (to_n)] + dependents.map { |d| d.to_graph(indents + 1) }).join("\n")
        end

        def siblings
          @sentence.tokens.select { |t| t.head_id == @head_id } - [self]
        end

        def head
          @sentence.tokens.select { |t| t.id == @head_id }.first
        end

        def dependents
          @sentence.tokens.select { |t| t.head_id == @id }.sort_by(&:id)
        end

        def find_appositive_head
          raise "Not an apposition" unless @relation == 'apos'
          if head.conjunction? and head.relation == 'apos'
            head.find_appositive_head
          else
            head
          end
        end

        def find_relation possible_relations
          rel, crit = possible_relations.shift
          if rel.nil?
          # raise "Found no relation"
          elsif crit.call self
            @relation = rel
          else
            find_relation possible_relations
          end
        end

        def map_part_of_speech!
          dependents.each(&:map_part_of_speech!)
          @upos = POS_MAP[@part_of_speech].first
          raise "No match found for pos #{part_of_speech.inspect}" unless @upos
          if feat = POS_MAP[@part_of_speech][1]
            @features += ((@features.empty? ? '' : '|') + feat)
          end
          # ugly, but the ugliness comes from UDEP
          @upos = 'ADJ' if @upos == 'DET' and @relation != 'det'
        end

        def relabel_graph!
          dependents.each(&:relabel_graph!)
          possible_relations = RELATION_MAPPING[@relation]
          case possible_relations
          when String
            @relation = possible_relations
          when Array
            find_relation possible_relations.dup
          when nil
          # do nothing: the token has already changed its relation
          else
            raise "Unknown value #{possible_relations.inspect} for #{@relation}"
          end
        end

        # attach subjunctions with 'mark' under their verbs and promote
        # the verb to take over the subjunction's relation. If the verb
        # is empty, the subjunction stays as head.
        def process_subjunction!
          # ignore if the subjunction has no dependents or only conj dependents.
          # NB: this requires that the function is called *after* processing conjunctions
          return if dependents.reject { |d| ['conj', 'cc'].include? d.relation }.empty?
          pred = dependents.select { |d| d.relation == 'pred' }
          raise "#{pred.size} PREDs under the subjunction #{to_n}:\n#{@sentence.to_graph}" unless pred.one?
          pred = pred.first
          # promote the subjunction if the verb is empty
          if pred.is_empty?
          pred.dependents.each { |d| d.head_id = id }
          @sentence.remove_token! pred
          # else demote the subjunction
          else
            pred.invert!('mark')
          end
        end



        # TODO: process "implicit pid" through APOS chain too
        def process_ellipsis!
          # First we find the corresponding overt token.
          # If there's an explicit pid slash, we'll grab that one.
          if pid and !subgraph_set.include?(pid)
            overt = pid
          # otherwise, try a conjunct
          elsif @relation == 'conj'
            overt = conj_head
          elsif @relation == 'apos'
            overt = find_appositive_head
          else
            return
          end

          dependents.each do |d|
            # check if there's a partner with the same relation under the overt node.
            # TODO: this isn't really very convincing when it comes to ADVs
            if partner = overt.dependents.select { |p| p != self and p.relation == d.relation }.first #inserted p != self
              partner = partner.find_remnant
              d.head_id = partner.id
              d.relation = 'remnant'
            # if there's no partner, just attach under the overt node, preserving the relation
            else
              d.head_id = overt.id
            end
          end
          @sentence.remove_token!(self)
        end

        def find_remnant
          if r = dependents.select { |d| d.relation == 'remnant' }.first
            r.find_remnant
          else
            self
          end
        end

        def process_copula!
          predicates = dependents.select { |d| d.relation == 'xobj' }
          raise "#{predicates.size} predicates under #{to_n}\n#{to_graph}" if predicates.size != 1
          predicates.first.promote!(nil, 'cop')
        end

        def process_preposition!
          raise "Only prepositions can be processed this way!" unless part_of_speech == 'R-'
          obliques = dependents.select { |d| d.relation == 'obl' }
          raise "#{obliques.size} oblique dependents under #{to_n}\n#{to_graph}" if obliques.size > 1
          return if obliques.empty? #shouldn't really happen, but in practice
          obliques.first.invert!("case") # , "adv")
        end

        def remove_empties!
          dependents.each(&:remove_empties!)
          if is_empty?
            dependents.each { |d| d.head_id = head_id; d.relation = 'remnant' }
            @sentence.remove_token! self
          end
        end

        # Changes coordinations  recursively from the bottom of the graph
        def change_coordinations!
          dependents.each(&:change_coordinations!)
          process_coordination! if conjunction?
        end

        def process_coordination!
          raise "Only coordinations can be processed this way!" unless conjunction?
          return if dependents.reject { |d| d.relation == 'aux' }.empty?
          distribute_shared_modifiers!
          dependents.reject { |d| d.relation == 'aux' }.first.promote!("conj", "cc")
        end

        def distribute_shared_modifiers!
          raise "Can only distribute over a conjunction!" unless conjunction?
          conjuncts, modifiers  = dependents.reject { |d| d.relation == 'aux' }.partition { |d|  d.relation == @relation or (d.relation == 'adv' and @relation == 'xadv') }
          first_conjunct = conjuncts.shift
          raise "No first conjunct under #{to_n}\n#{to_graph}" unless first_conjunct
          raise "The first conjunct is a misannotated conjunction in #{to_n}\n#{to_graph}" if first_conjunct.conjunction? and first_conjunct.dependents.empty?
          modifiers.each do |m|
            m.head_id = first_conjunct.id
            conjuncts.each { |c| c.add_slash! [m.id, m.relation] }
          end
        end

        def add_slash!(slash)
          @slashes << slash
        end

        # Inverts the direction of a dependency relation. By default the
        # labels are also swapped, but new relations can be specified
        # for both the new dependent and the new head.
        def invert!(new_dependent_relation = nil, new_head_relation = nil)
          raise "Cannot promote a token under root!" if @head_id == 0
          new_dependent_relation ||= @relation
          new_head_relation ||= head.relation
          new_head_id = head.head_id

          head.head_id = @id
          head.relation = new_dependent_relation
          @head_id = new_head_id
          self.relation = new_head_relation
        end

        # promotes a node to its head's place. The node takes over its
        # former head's relation and all dependents. The new relation
        # for these dependents can be specified; if it is not, they will
        # keep their former relation. The former head is made a
        # dependent of the node (with a specified relation) or,
        # if it is an empty node, destroyed.

        def promote!(new_sibling_relation = nil, new_dependent_relation = 'aux')
          raise "Cannot promote a token under root!" if @head_id == 0
          new_head_relation = head.relation
          new_head_id = head.head_id

          # move all dependents of the former head to the new one
          siblings.each do |t|
            t.head_id = @id
            # ugly hack to avoid overwriting the aux relation here (aux siblings aren't really siblings)
            t.relation = new_sibling_relation if (new_sibling_relation and t.relation != 'aux')
          end

          # remove the former head if it was empty
          if head.is_empty?
            @sentence.remove_token!(head)
          # else make it a dependent of the new head
          else
            head.head_id = @id
            head.relation = new_dependent_relation
          end

          @head_id = new_head_id
          # don't use relation=, as we don't want this relation to be
          # copied down a tree of conjunctions
          @relation = new_head_relation
        end
      end
    end
  end
end

module PROIEL
  module Converter
    # This converts to the CoNLL-X format as described on
    # http://ilk.uvt.nl/conll/#dataformat.
    #
    # The conversion removes empty tokens. PRO tokens are completely ignored,
    # while null C and null V tokens are eliminated by attaching their
    # dependents to the first non-null ancestor and labelling them with a
    # concatenation of dependency relations.
    #
    # Sequences of whitespace in forms and lemmas are represented by '.'.
    class CoNLLX
      class << self
        def process(tb, options)
          tb.sources.each do |source|
            source.sentences.each do |sentence|
              process_sentence(tb, sentence)
            end
          end
        end

        def process_sentence(tb, sentence)
          tokens = sentence.tokens

          # Generate 1-based continguous numbering of overt tokens with
          # null V and null C tokens appended at the end. We do this
          # manually to ensure that the numbering is correct whatever the
          # sequence is in the treebank.
          id_map = Hash.new { |h, k| h[k] = h.keys.length + 1 }
          tokens.select(&:has_content?).each { |t| id_map[t] } # these blocks have side-effects
          tokens.reject(&:has_content?).reject(&:pro?).each { |t| id_map[t] }

          # Iterate overt tokens and print one formatted line per token.
          tokens.select(&:has_content?).each do |token|
            this_number = id_map[token]
            head_number, relation = find_lexical_head_and_relation(id_map, tb, token)
            form = format_text(token.form)
            lemma = format_text(token.lemma)
            pos_major, pos_full = format_pos(token)
            morphology = format_morphology(token)

            puts [this_number, form, lemma, pos_major, pos_full,
                  morphology, head_number, relation, '_', '_'].join("\t")
          end

          # Separate sentences by an empty line.
          puts
        end

        def format_text(s)
          s.gsub(/[[:space:]]+/, '.')
        end

        def format_pos(token)
          [token.part_of_speech_hash[:major], token.part_of_speech]
        end

        def format_morphology(token)
          token.morphology_hash.map do |k, v|
            # Remove inflection tag except when set to inflecting
            if k == :inflection and v =='i'
              nil
            else
              "#{k.upcase[0..3]}#{v}"
            end
          end.compact.join('|')
        end

        def find_lexical_head_and_relation(id_map, tb, t, rel = '')
          new_relation = rel + t.relation

          if t.is_root?
            [0, new_relation]
          elsif t.head.has_content?
            [id_map[t.head], new_relation]
          else
            find_lexical_head_and_relation(id_map, tb, t.head, "#{new_relation}(#{id_map[t.head]})")
          end
        end
      end
    end
  end
end

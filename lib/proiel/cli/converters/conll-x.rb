module PROIEL
  module Converter
    # This converts to the CoNLL-X format as described on http://ilk.uvt.nl/conll/#dataformat.
    class CoNLLX
      class << self
        def process(tb, options)
          tb.sources.each do |source|
            source.divs.each do |div|
              div.sentences.each do |sentence|
                id_to_number = {}

                # Do not care about prodrop tokens
                tk = sentence.tokens.reject { |t| t.empty_token_sort == 'P' }
                
                # Renumber to make the sequence continguous after prodrop tokens where left out
                tk.map(&:id).each_with_index.each do |id, i|
                  id_to_number[id] = i + 1
                end

                id_to_token = tk.inject({}) { |h, t| h.merge({t.id => t}) }

                tk.each do |token|
                  unless token.is_empty?
                    this_number = id_to_number[token.id]
                    head_number, relation = find_lexical_head_and_relation(id_to_number, id_to_token, token)
                    form = token.form.gsub(/[[:space:]]/, '.')
                    lemma = token.lemma.gsub(/[[:space:]]/, '.')
                    pos_major = token.part_of_speech_hash[:major]
                    pos_full = token.part_of_speech
                    morphology = format_morphology(token)

                    puts [this_number, form, lemma, pos_major, pos_full,
                          morphology, head_number, relation, "_", "_"].join("\t")
                  end
                end

                puts
              end
            end
          end
        end

        def format_morphology(token)
          token.morphology_hash.map do |k, v|
            # Remove inflection tag unless when set to inflecting
            if k == :inflection and v =='i'
              nil
            else
              "#{k.upcase[0..3]}#{v}"
            end
          end.compact.join('|')
        end

        def find_lexical_head_and_relation(id_to_number, id_to_token, t, rel = '')
          if t.is_root?
            [0, rel + t.relation] # FIXME: may be empty token anyway
          elsif id_to_token[t.head_id].has_content?
            [id_to_number[t.head_id], rel + t.relation]
          else
            find_lexical_head_and_relation(id_to_number, id_to_token, id_to_token[t.head_id], rel + "#{t.relation}(#{id_to_number[t.head_id]})")
          end
        end
      end
    end
  end
end

module PROIEL::Converter
  class TNT
    class << self
      def process(tb, options)
        tb.sources.each do |source|
          puts "%% Source #{source.id}"
          puts '--'

          source.divs.each do |div|
            div.sentences.each do |sentence|
              puts "%% Sentence #{sentence.id}"
              sentence.tokens.each do |token|
                if options['pos'] or options['morphology']
                  unless token.form.nil? or token.pos.nil?
                    if options['morphology']
                      unless token.morphology.nil?
                        puts [token.form, token.pos + token.morphology].join("\t")
                      end
                    else
                      puts [token.form, token.pos].join("\t")
                    end
                  end
                else
                  puts token.form
                end
              end
              puts '--'
            end
          end
        end
      end
    end
  end
end

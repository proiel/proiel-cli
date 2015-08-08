module PROIEL
  module Converter
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
                  unless token.form.nil?
                    if options['morphology']
                      puts [token.form, token.pos + token.morphology].join("\t")
                    else
                      puts [token.form, token.pos].join("\t")
                    end
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
end

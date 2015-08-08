module PROIEL
  module Converter
    class Text
      class << self
        def process(tb, options)
          tb.sources.each do |source|
            puts "% export_time = #{Time.now}"
            puts "% title = #{source.title}"
            puts "% author = #{source.author}"
            puts "% citation_part = #{source.citation_part}"
            puts "% language = #{source.language}"

            # TODO
            #Proiel::Metadata.fields.each do |f|
            #  file.puts "% #{f} = #{s.send(f)}" unless s.send(f).nil?
            #end

            source.divs.each do |div|
              puts
              puts "# #{div.title}"
              puts

              if options['diffable']
                print_diffable_div(div)
              else
                print_formatted_div(div)
              end
            end
          end
        end

        def print_formatted_div(div)
          p = ''
          p += div.presentation_before unless div.presentation_before.nil?

          current_citation = nil

          div.sentences.each do |sentence|
            p += sentence.presentation_before unless sentence.presentation_before.nil?

            sentence.tokens.each do |token|
              if token.has_content?
                new_citation = token.citation_part

                if current_citation != new_citation
                  p += "§#{new_citation.gsub(/\s+/, '_')} "
                  current_citation = new_citation
                end

                p += [token.presentation_before,
                      token.form,
                      token.presentation_after].compact.join
              end
            end

            p += sentence.presentation_after unless sentence.presentation_after.nil?
          end

          p += div.presentation_after unless div.presentation_after.nil?

          p = p.strip.gsub(/ +/, ' ').split("\n").collect do |line|
              line.length > 80 ? line.gsub(/(.{1,80})(\s+|$)/, "\\1\n").strip : line
            end * "\n"

          puts p
        end

        def print_diffable_div(div)
          current_citation = nil

          p = ''
          pb = div.presentation_before || ''

          div.sentences.each do |sentence|
            pb += sentence.presentation_before || ''

            sentence.tokens.each do |token|
              if token.has_content?
                if current_citation != token.citation_part
                  puts p unless p.empty?
                  p = "§#{token.citation_part.gsub(/\s+/, '_')} "
                  current_citation = token.citation_part
                end

                p += [pb,
                      token.presentation_before,
                      token.form,
                      token.presentation_after].compact.join
                pb = ''
              end
            end

            p += sentence.presentation_after unless sentence.presentation_after.nil?
          end

          p += div.presentation_after unless div.presentation_after.nil?

          puts p unless p.empty?
        end
      end
    end
  end
end

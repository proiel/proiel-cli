module PROIEL
  module Commands
    class CountWords < Command
      class << self
        def init_with_program(prog)
          prog.command(:info) do |c|
            c.syntax 'info [options] filename(s)'
            c.description 'Show information about the treebank'

            c.action do |args, options|
              if args.empty?
                STDERR.puts 'Missing filename(s). Use --help for more information.'
              else
                process(args, options)
              end
            end
          end
        end

        def process(args, options)
          tb = PROIEL::Treebank.new

          args.each do |filename|
            STDERR.puts "Reading #{filename}...".green if options['verbose']

            tb.load_from_xml(filename)
          end

          puts "Loaded treebank files contain #{tb.sources.count} source(s)".yellow
          puts "   Overall size: #{tb.statistics.sentence_count} sentence(s), #{tb.statistics.token_count} token(s)"
          puts

          tb.sources.each_with_index do |source, i|
            n = source.statistics.sentence_count
            r = source.statistics.reviewed_sentence_count * 100.0 / n
            a = source.statistics.annotated_sentence_count * 100.0 / n

            puts "#{i + 1}. #{pretty_title(source)}".yellow
            puts "   Version:      #{source.date}"
            puts "   License:      #{pretty_license(source)}"
            puts "   Language:     #{pretty_language(source)}"
            puts "   Printed text: #{pretty_printed_text_info(source)}"
            puts "   Electr. text: #{pretty_electronic_text_info(source)}"
            puts "   Size:         #{n} sentence(s), #{source.statistics.token_count} token(s)"
            puts "   Annotation:   %.2f%% reviewed, %.2f%% annotated" % [r, a]
          end
        end

        def pretty_language(source)
          case source.language
          when 'lat'
            'Latin'
          else
            "Unknown (language code #{source.language})"
          end
        end

        def pretty_printed_text_info(source)
          [source.printed_text_title,
           source.printed_text_editor ? "ed. #{source.printed_text_editor}" : nil,
           source.printed_text_publisher,
           source.printed_text_place,
           source.printed_text_date].compact.join(', ')
        end

        def pretty_electronic_text_info(source)
          [source.electronic_text_title,
           source.electronic_text_editor ? "ed. #{source.electronic_text_editor}" : nil,
           source.electronic_text_publisher,
           source.electronic_text_place,
           source.electronic_text_date].compact.join(', ')
        end

        def pretty_license(source)
          if source.license_url
            "#{source.license} (#{source.license_url})"
          else
            source.license
          end
        end

        def pretty_title(source)
          [source.author, source.title].compact.join(', ')
        end
      end
    end
  end
end

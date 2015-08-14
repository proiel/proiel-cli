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

            puts "#{i + 1}. #{source.pretty_title}".yellow
            puts "   Version:      #{source.date}"
            puts "   License:      #{source.pretty_license}"
            puts "   Language:     #{source.pretty_language}"
            puts "   Printed text: #{source.pretty_printed_text_info}"
            puts "   Electr. text: #{source.pretty_electronic_text_info}"
            puts "   Size:         #{n} sentence(s), #{source.statistics.token_count} token(s)"
            puts "   Annotation:   %.2f%% reviewed, %.2f%% annotated" % [r, a]
          end
        end
      end
    end
  end
end

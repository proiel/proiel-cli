module PROIEL
  module Commands
    class Alignment < Command
      class << self
        def init_with_program(prog)
          prog.command(:alignment) do |c|
            c.syntax 'alignment [options] filename(s)'
            c.description 'Build an alignment matrix'

            c.option 'logdir', '--log-directory log', 'Enable logging and save logs to the given directory'

            c.action { |args, options| process(args, options) }
          end
        end

  BLACKLIST = [
    # Lacuna in Gothic NT
    47183, 47184,

    # ? in Armenian NT
    75413, 61271, 61428, 61747, 64309, 61748, 62506,
  ]
        def process(args, options)
          tb = PROIEL::Treebank.new

          args.each do |filename|
            STDERR.puts "Reading #{filename}...".green if options['verbose']

            tb.load_from_xml(filename)
          end

          puts %i(original translation).join("\t")

          tb.sources.each do |source|
            if source.alignment_id
              alignment = tb.find_source(source.alignment_id)
              matrix = PROIEL::Alignment::Builder.compute_matrix(alignment, source, BLACKLIST, options['logdir'])

              matrix.each do |row|
                puts [row[:original].join(','), row[:translation].join(',')].join("\t")
              end
            end
          end
        end
      end
    end
  end
end

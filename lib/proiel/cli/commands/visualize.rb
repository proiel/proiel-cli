module PROIEL
  module Commands
    class Visualize < Command
      class << self
        def init_with_program(prog)
          prog.command(:visualize) do |c|
            c.syntax 'visualize [OPTION(S)] FILENAME(S)'
            c.description 'Visualize treebank graphs'
            c.option 'objects', '--objects sentences|divs|sources|SENTENCE-ID', 'Objects to visualize (default: sentences)'
            c.option 'format', '--format png|svg|dot', 'Output format (default: svg)'
            c.option 'layout', '--layout classic|linearized|packed|modern', 'Graph layout (default: classic)'

            c.action { |args, options| process(args, options) }
          end
        end

        LAYOUTS = %w(classic linearized packed modern)

        def process(args, options)
          objects = options['objects'] || 'sentences'
          format = options['format'] || 'svg'
          layout = options['layout'] || 'classic'

          unless LAYOUTS.include?(layout)
            STDERR.puts "Invalid layout"
            exit 1
          end

          if objects != 'sentences' and objects != 'divs' and objects != 'sources' and objects.to_i.to_s != objects
            STDERR.puts "Invalid object type"
            exit 1
          end

          if format != 'png' and format != 'svg' and format != 'dot'
            STDERR.puts "Invalid format"
            exit 1
          end

          tb = PROIEL::Treebank.new

          if args.empty?
            STDERR.puts "Reading from standard input...".green if options['verbose']
            tb.load_from_xml(STDIN)
          else
            args.each do |filename|
              STDERR.puts "Reading #{filename}...".green if options['verbose']

              tb.load_from_xml(filename)
            end
          end

          tb.sources.each do |source|
            case objects
            when 'sources'
              puts "This can take a very, very long time... Be patient!"
              save_graph layout, format, source
            when 'divs'
              save_graphs source.divs, layout, format, source.id, source.divs.count
            when 'sentences'
              save_graphs source.sentences, layout, format, source.id, source.sentences.count
            else
              object = tb.find_sentence(objects.to_i)
              save_graph(layout, format, object) if object
            end
          end
        end

        def save_graph(template, format, graph)
          PROIEL::Visualization::Graphviz.generate_to_file(template, graph, format, "#{graph.id}.#{format}")
        end

        def save_graphs(enumerator, template, format, title, n)
          pbar = ProgressBar.create progress_mark: 'X', remainder_mark: ' ', title: title, total: n

          enumerator.each_with_index do |object, i|
            save_graph template, format, object
            pbar.increment
          end
        end
      end
    end
  end
end

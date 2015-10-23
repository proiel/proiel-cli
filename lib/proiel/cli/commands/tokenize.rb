module PROIEL
  module Commands
    class Tokenize < Command
      class << self
        def init_with_program(prog)
          prog.command(:tokenize) do |c|
            c.syntax 'tokenize'
            c.description 'Tokenize raw text'
            c.syntax '[options] filename'

            c.action { |args, options| process(args, options) }
          end
        end

        def process(args, options)
          if args.empty?
            STDERR.puts 'Missing filename. Use --help for more information.'
            exit 1
          end

          if args.length > 1
            STDERR.puts 'Too many filenames. Use --help for more information.'
            exit 1
          end

          builder = Builder::XmlMarkup.new(target: STDOUT, indent: 2)
          builder.instruct! :xml, version: '1.0', encoding: 'UTF-8'

          filename = args.first

          File.open(filename, 'r') do |file|
            header = read_header(file)
            body = read_body(file)

            builder.proiel('export-time' => header.export_time, 'schema-version' => '2.0') do
              builder.source(id: header.id, language: header.language) do
                builder.title header.title
                builder.author header.author
                builder.tag!('citation-part', header.citation_part)

                tokenize(builder, body)
              end
            end
          end
        end

        def tokenize(builder, body)
          citation_part = nil

          body.each_with_index do |sd_body, i|
            builder.div(title: sd_body[:title]) do
              sd_body[:contents].split(/(@[^ ]+|§[^ ]+)/).map do |s|
                if s[0] == '§' or s[0] == '@'
                  s
                else
                  # It's sensible to place the break not immediately after probable
                  # sentence-breaking punctuation like periods and question marks, but
                  # after the punctuation mark and characters typically used in pairs,
                  # like brackets and apostrophes.
                  s.gsub(/([\.:;\?!]+[\s†\]\)"']*)/, '\1|')
                end
              end.join.split('|').each_with_index do |s_body, j|
                builder.sentence(status_tag: 'unannotated') do
                  leftover_before = ''

                  # Preserve linebreaks in the text.
                  s_body.gsub!(/\s*[\n\r]/, "\u2028")

                  s_body.scan(/([^@§\p{Word}]*)([\p{Word}]+|@[^ ]+|§[^ ]+)([^@§\p{Word}]*)/).each do |(before, form, after)|
                    case form
                    when /^@(.*)$/
                      leftover_before += before unless before.nil?
                      leftover_before += $1
                      leftover_before += after unless after.nil?
                    when /^§(.*)$/
                      leftover_before += before unless before.nil?
                      citation_part = $1
                      leftover_before += after unless after.nil?
                    else
                      before = leftover_before + before
                      leftover_before = ''

                      attrs = { citation_part: citation_part, form: form }
                      attrs[:presentation_before] = before unless before == ''
                      attrs[:presentation_after] = after unless after == ''

                      builder.token(attrs)
                    end
                  end
                end
              end
            end
          end
        end

        VALID_METADATA_FIELDS =
                %w(title author citation_part language id

                  principal funder distributor distributor_address date
                  license license_url
                  reference_system
                  editor editorial_note
                  annotator reviewer

                  electronic_text_editor electronic_text_title
                  electronic_text_version
                  electronic_text_publisher electronic_text_place electronic_text_date
                  electronic_text_original_url
                  electronic_text_license electronic_text_license_url

                  printed_text_editor printed_text_title
                  printed_text_edition
                  printed_text_publisher printed_text_place printed_text_date)

        def read_header(f)
          f.rewind

          OpenStruct.new.tap do |hdr|
            # We expect a header first, each line starting with %, and we
            # assume that the header ends with the first line that does
            # not start with %.
            f.each_line do |l|
              l.chomp!

              case l
              when /^%/
                field, value = l.sub(/^%\s*/, '').split(/\s*=\s*/, 2)

                case field
                when 'id', 'export_time', *VALID_METADATA_FIELDS
                  hdr[field] = value.strip
                else
                  STDERR.puts "Invalid header field #{field}. Ignoring.".yellow
                end
              else
                break
              end
            end
          end
        end

        def read_body(f)
          f.rewind

          Array.new.tap do |bdy|
            f.each_line do |l|
              case l
              when /^%/
                # Ignore header
              when /^\s*$/
                # Ignore empty lines
              when /^#/
                # New source division started
                bdy << { title: l.sub(/^#/, '').strip, contents: '' }
              else
                bdy << { title: '', contents: '' } if bdy.empty?
                bdy.last[:contents] += l
              end
            end
          end
        end
      end
    end
  end
end

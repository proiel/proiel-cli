module PROIEL
  module Converter
    class CCMH
      CHARACTER_MAP = {
        'a' => 0x0430, # a
        '^a' => [ 0x0430, 0x0484 ], # a + round circumflex
        '(a' => [ 0x0430, 0x0485 ], # a + spiritus asper
        'b' => 0x0431, # b
        'v' => 0x0432, # v
        'g' => 0x0433, # g
        'd' => 0x0434, # d
        'e' => 0x0435, # e
        '^e' => [ 0x0435, 0x0484 ], # e + round circumflex
        '(e' => [ 0x0435, 0x0485 ], # e + spiritus asper
        'Z' => 0x0436, # ž
        'D' => 0x0455, # dzelo
        'z' => 0x0437, # z
        'i' => 0x0438, # i
        '~i' => [ 0x0438, 0x0306 ], # i + kratkaja
        '^i' => [ 0x0438, 0x0484 ], # i + round circumflex
        '(i' => [ 0x0438, 0x0485 ], # i + spiritus asper
        'I' => 0x0456, # i
        '(I' => [ 0x0456, 0x0485 ], # i + spiritus asper
        'J' => 0xa647, # i
        '(J' => [ 0xa647, 0x0485 ], # i + spiritus asper
        'G' => 0xa649, # g'
        'k' => 0x043a, # k
        'l' => 0x043b, # l
        '^l' => [ 0x043b, 0x0484 ], # l + round circumflex
        '(l' => [ 0x043b, 0x0485 ], # l + spiritus asper
        'm' => 0x043c, # m
        'n' => 0x043d, # n
        '^n' => [ 0x043d, 0x0484 ], # n + round circumflex
        'o' => 0x043e, # o
        '(o' => [ 0x043e, 0x0485 ], # o + spiritus asper
        'p' => 0x043f, # p
        'r' => 0x0440, # r
        '(r' => [ 0x0440, 0x0485 ], # r + spiritus asper
        's' => 0x0441, # s
        't' => 0x0442, # t
        '^t' => [ 0x0442, 0x0484 ], # t + round circumflex
        'u' => [ 0x043e, 0x0443 ], # u
        '(u' => [ 0x043e, 0x0443, 0x0485 ], # u + spiritus asper (s.a. is over the final half of the digraph)
        'f' => 0x0444, # f
        'T' => 0x0473, # th
        'x' => 0x0445, # x
        'w' => 0x0461, # o
        '~w' => [ 0x0461, 0x0306 ], # o + kratkaja
        '(w' => [ 0x0461, 0x0485 ], # o + spiritus asper
        'q' => 0x0449, # št
        'c' => 0x0446, # c
        'C' => 0x0447, # č
        'S' => 0x0448, # š
        '&' => 0x044a, # big jer
        '$' => 0x044c, # small jer
        '^$' => [ 0x044c, 0x0484 ], # small jer + round circumflex
        'y' => 0xa651, # y
        '@' => 0x0463, # ě
        '(@' => [ 0x0463, 0x0485 ], # ě + spiritus asper
        'ju' => 0x044e, # ju
        '~ju' => [ 0x044e, 0x0306 ], # ju + kratkaja
        '^ju' => [ 0x044e, 0x0484 ], # ju + round circumflex
        '(ju' => [ 0x044e, 0x0485 ], # ju + spiritus asper
        'E' => 0x0467, # small jus
        '^E' => [ 0x0467, 0x0484 ], # small jus + round circumflex
        'jE' => 0x0469, # j-small jus
        '~jE' => [ 0x0469, 0x0306 ], # j-small jus + kratkaja
        '(jE' => [ 0x0469, 0x0485 ], # j-small jus + spiritus asper
        'O' => 0x046b, # big jus
        '^O' => [ 0x046b, 0x0484 ], # big jus + round circumflex
        '(O' => [ 0x046b, 0x0485 ], # big jus + spiritus asper
        'jO' => 0x046d, # j-big jus
        '^jO' => [ 0x046d, 0x0484 ], # j-big jus + round circumflex
        '(jO' => [ 0x046d, 0x0485 ], # j-big jus + spiritus asper
        'U' => 0x0475, # ü
        '(U' => [ 0x0475, 0x0485 ], # ü + spiritus asper
        'Y' => 0x0443, # interpolated u as part of uk
        'A' => 0xa659, # "nasal jer"
        'jw' => [ 0x0461, 0x0308 ], # o + trema

        '*a' => 0x0410, # A
        '*(a' => [ 0x0410, 0x0485 ], # A + spiritus asper
        '*b' => 0x0411, # B
        '*!b' => [ 0x0021, 0x0411 ], # !B
        '*v' => 0x0412, # V
        '*g' => 0x0413, # G
        '*!g' => [ 0x0021, 0x0413 ], # !G
        '*d' => 0x0414, # D
        '*e' => 0x0415, # E
        '*(e' => [ 0x0415, 0x0485 ], # E + spiritus asper
        '*Z' => 0x0416, # Ž
        '*z' => 0x0417, # Z
        '*i' => 0x0418, # I
        '*I' => 0x0406, # I
        '*J' => 0xa646, # I
        '(*J' => [ 0xa646, 0x0485 ], # I + spiritus asper
        '*(J' => [ 0xa646, 0x0485 ], # I + spiritus asper
        '*!J' => [ 0x0021, 0xa646 ], # !I
        '*G' => 0xa648, # G'
        '*k' => 0x041a, # K
        '*l' => 0x041b, # L
        '*m' => 0x041c, # M
        '*n' => 0x041d, # N
        '*o' => 0x041e, # O
        '(*o' => [ 0x041e, 0x0485 ], # O + spiritus asper
        '*(o' => [ 0x041e, 0x0485 ], # O + spiritus asper
        '*!o' => [ 0x0021, 0x041e ], # !O
        '*p' => 0x041f, # P
        '*r' => 0x0420, # R
        '*s' => 0x0421, # S
        '*t' => 0x0422, # T
        '*u' => [ 0x041e, 0x0443], # U FIXME: this may really be OU as well as Ou
        '*(u' => [ 0x041e, 0x0443, 0x0485 ], # u + spiritus asper
        '*f' => 0x0424, # F
        '*x' => 0x0425, # X
        '*w' => 0x0460, # O
        '*~w' => [ 0x0460, 0x0306 ], # O + kratkaja
        '*(w' => [ 0x0460, 0x0485 ], # O + spiritus asper
        '*!~w' => [ 0x0021, 0x0460, 0x0306 ], # !O + kratkaja
        '*q' => 0x0429, # Št
        '*c' => 0x0426, # C
        '*C' => 0x0427, # Č
        '*S' => 0x0428, # Š
        '*&' => 0x042a, # Big jer
        '*$' => 0x042c, # Small jer
        '*y' => 0xa650, # Y
        '*@' => 0x0462, # Ě
        '*(@' => [ 0x0462, 0x0485 ], # Ě + spiritus asper
        '*ju' => 0x042e, # Ju
        '*(ju' => [ 0x042e, 0x0485 ], # Ju + spiritus asper
        '*jw' => [ 0x0460, 0x0308 ], # O + trema
        "'" => 0xa67f, # poerok (non-combining)

        ' ' => ' ',
        '=' => '=',
        '[' => '[',
        ']' => ']',
        '{' => '{',
        '}' => '}',
        '?' => '?',
        '!' => '!',
        ':' => ':',
        ' .' => '.', # CCMH uses an extra space before the symbol
        '-' => '-',
      }

      REVERSE_CHARACTER_MAP = Hash[*CHARACTER_MAP.map do |ccmh, utf8|
          case utf8
          when Fixnum
            [[utf8].pack('U*'), ccmh]
          when Array
            [utf8.pack('U*'), ccmh]
          else
            [utf8, ccmh]
          end
        end.flatten].freeze

      REVERSE_REGEXP = Regexp.union(*REVERSE_CHARACTER_MAP.keys).freeze

      class << self
        def print_line(citation_upper, citation_lower, string)
          unless string == ''
            puts [translate_citation(citation_upper, citation_lower), reencode_string(string)].join(' ')
          end
        end

        def translate_citation(cu, cl)
          case cl
          when /^MATT (\d+)|.(\d+)$/
            book, chapter, verse = 1, $1.to_i, $2.to_i
          when /^MARK (\d+)|.(\d+)$/
            book, chapter, verse = 2, $1.to_i, $2.to_i
          when /^LUKE (\d+)|.(\d+)$/
            book, chapter, verse = 3, $1.to_i, $2.to_i
          when /^JOHN (\d+)|.(\d+)$/
            book, chapter, verse = 4, $1.to_i, $2.to_i
          else
            book, chapter, verse = 0, 0, 0
          end

          '%1d%02d%02d%1d0' % [book, chapter, verse, 0]
        end

        def reencode_string(s)
          t = ''

          s.scan(REVERSE_REGEXP) do |c|
            t += REVERSE_CHARACTER_MAP[c]
          end

          t
        end

        def process(tb, options)
          tb.sources.each do |source|
            citation_upper = source.citation_part

            source.divs.each do |div|
              citation_lower = nil
              s = div.presentation_before || ''

              div.sentences.each do |sentence|
                s += sentence.presentation_before || ''

                sentence.tokens.each do |token|
                  unless token.is_empty?
                    if citation_lower and citation_lower != token.citation_part
                      print_line(citation_upper, citation_lower, s)
                      s = ''
                    end

                    citation_lower = token.citation_part
                    s += token.presentation_before || ''
                    s += token.form
                    s += token.presentation_after || ''
                  end
                end

                s += sentence.presentation_after || ''
              end

              s += div.presentation_after || ''

              print_line(citation_upper, citation_lower, s)
            end
          end
        end
      end
    end
  end
end

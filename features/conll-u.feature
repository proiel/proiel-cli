Feature: Converting to CoNLL-U

Scenario: Linguistically valid Proiel XML is converted to CoNLL-U
  When I run `proiel convert conll-u ../../features/caes-gal-convertible.xml`
  Then the output should have 32329 lines

Scenario: Linguistically invalid Proiel XML is converted to CoNLL-U
  When I run `proiel convert conll-u ../../features/caes-gal-nonconvertible.xml`
  Then the output should be empty
  Then the errors should contain "Cannot convert 52577"
  Then the errors should contain "Cannot convert 52599"
  Then the errors should contain "Cannot convert 52677"
  Then the errors should contain "Cannot convert 52719"
  Then the errors should contain "Cannot convert 52742"
  Then the errors should contain "Cannot convert 52747"
  Then the errors should contain "Cannot convert 64207"

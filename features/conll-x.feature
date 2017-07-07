Feature: Converting to CoNLL-X

Scenario: Valid PROIEL XML is converted to CoNLL-X
  When I run `proiel convert conll-x ../../features/cic-att.xml`
  Then the output should be equal to file "features/cic-att.conll"

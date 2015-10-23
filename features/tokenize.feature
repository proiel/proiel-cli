Feature: Tokenizing text

  Scenario: Help is displayed
    When I run `proiel tokenize --help`
    Then the output should contain "Usage:"

  Scenario: Text is tokenized as PROIEL XML
    When I run `proiel tokenize ../../features/dummy.text`
    Then the output should be equal to file "features/dummy-tokenized.xml"

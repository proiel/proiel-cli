Feature: Converting to LexC

  Scenario: Help is displayed
    When I run `proiel convert lexc --help`
    Then the output should contain "Usage:"

  Scenario: POS is converted to LexC
    When I run `proiel convert lexc ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should be equal to file "features/dummy.lexc"

  Scenario: POS and morpholgy are converted to LexC
    When I run `proiel convert lexc --morphology ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should be equal to file "features/dummy-with-morphology.lexc"

Feature: Converting to TnT

  Scenario: Help is displayed
    When I run `proiel convert tnt --help`
    Then the output should contain "Usage:"

  Scenario: POS is converted to TnT
    When I run `proiel convert tnt --pos ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should be equal to file "features/dummy.tnt"

  Scenario: POS and morpholgy are converted to TnT
    When I run `proiel convert tnt --morphology ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should be equal to file "features/dummy-with-morphology.tnt"

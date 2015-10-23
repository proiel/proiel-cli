Feature: Converting to TigerXML

  Scenario: Help is displayed
    When I run `proiel convert tiger --help`
    Then the output should contain "Usage:"

  Scenario: Treebank is converted to TigerXML
    When I run `proiel convert tiger ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should be equal to file "features/dummy.tiger"

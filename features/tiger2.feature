Feature: Converting to Tiger2

  Scenario: Help is displayed
    When I run `proiel convert tiger2 --help`
    Then the output should contain "Usage:"

  Scenario: Treebank is converted to Tiger2
    When I run `proiel convert tiger2 ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should be equal to file "features/dummy.tiger2"

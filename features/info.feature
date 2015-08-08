Feature: Info

  Scenario: A filename is missing
    When I run `proiel info`
    Then the output should contain "Missing filename(s)"

  Scenario: Help is displayed
    When I run `proiel info --help`
    Then the output should contain "Usage:"

  Scenario: Info is displayed
    When I run `proiel info ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "Version: "
    Then the output should contain "Language: "
    Then the output should contain "Size: "
    Then the output should contain "5 sentence(s)"
    Then the output should contain "119 token(s)"

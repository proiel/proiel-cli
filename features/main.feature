Feature: Main options

  Scenario: With --version
    When I run `proiel --version`
    Then the output should contain "proiel"

  Scenario: Help is displayed
    When I run `proiel --help`
    Then the output should contain "Usage:"

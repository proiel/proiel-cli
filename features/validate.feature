Feature: Validation

  Scenario: A filename is missing
    When I run `proiel validate`
    Then the output should contain "Missing filename(s)"

  Scenario: Help is displayed
    When I run `proiel validate --help`
    Then the output should contain "Usage:"

  Scenario: Validation fails because of invalid antecedent_id references
    When I run `proiel validate ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "is invalid"
    Then the output should contain "antecedent_id references a token in a different sentence"
    Then the output should contain "680741"
    Then the output should contain "680749"
    Then the output should contain "680755"

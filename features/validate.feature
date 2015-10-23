Feature: Validation

  Scenario: A filename is missing
    When I run `proiel validate`
    Then the output should contain "Missing filename(s)"

  Scenario: Help is displayed
    When I run `proiel validate --help`
    Then the output should contain "Usage:"

  Scenario: Validation succeeds
    When I run `proiel validate ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "is valid"

  Scenario: Validation fails because of invalid antecedent_id references
    When I run `proiel validate ../../features/invalid-antecedent-id.xml`
    Then the output should contain "is invalid"
    Then the output should contain "Token 680725: antecedent_id references an unknown token"
    Then the output should contain "Token 680741: antecedent_id references a token in a different div"
    Then the output should contain "Token 680749: head_id references a token in a different sentence"
    Then the output should contain "Token 680749: antecedent_id references a token in a different div"
    Then the output should contain "Token 680751: antecedent_id references a token in a different div"
    Then the output should contain "Token 680755: antecedent_id references a token in a different div"
    Then the output should contain "Token 680759: slash_id references a token in a different sentence"

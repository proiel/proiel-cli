Feature: Grepping

  Scenario: A pattern is missing
    When I run `proiel grep`
    Then the output should contain "Missing pattern"

  Scenario: Help is displayed
    When I run `proiel grep --help`
    Then the output should contain "Usage:"

  Scenario: Searching for "Gallia"
    When I run `proiel grep Gallia ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "est omnis divisa in partes tres"

  Scenario: Searching for "GALLIA"
    When I run `proiel grep GALLIA ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should not contain "est omnis divisa in partes tres"

  Scenario: Searching for "GALLIA" with ignore case
    When I run `proiel grep -i GALLIA ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "est omnis divisa in partes tres"

  Scenario: Searching for "Gallia" on token level
    When I run `proiel grep --level token Gallia ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "680720"
    Then the output should contain "Gallia"

  Scenario: Searching for "GALLIA" on token level with ignore case on token level
    When I run `proiel grep -i --level token GALLIA ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "680720"
    Then the output should contain "Gallia"
    Then the output should not contain "est omnis divisa in partes tres"

  Scenario: Searching for "Gallia" on sentence level
    When I run `proiel grep --level sentence Gallia ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "52548"
    Then the output should contain "Gallia"
    Then the output should contain "est omnis divisa in partes tres"

  Scenario: Searching for "GALLIA" on sentence level with ignore case on token level
    When I run `proiel grep -i --level sentence GALLIA ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "52548"
    Then the output should contain "Gallia"
    Then the output should contain "est omnis divisa in partes tres"

  Scenario: Searching with the pattern "^i" on token level
    When I run `proiel grep --level token '^i' ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "incolunt"
    Then the output should contain "inter"
    Then the output should contain "important"
    Then the output should not contain "prohibent"
    Then the output should not contain "finibus"
    Then the output should not contain "lingua"

  Scenario: Searching with the pattern "i" on token level
    When I run `proiel grep --level token 'i' ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "incolunt"
    Then the output should contain "inter"
    Then the output should contain "important"
    Then the output should contain "prohibent"
    Then the output should contain "finibus"
    Then the output should contain "lingua"

  Scenario: Searching with the pattern "^G" on sentence level
    When I run `proiel grep --level sentence '^G' ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "Gallia"
    Then the output should contain "Gallos"
    Then the output should not contain "Germanis"

  Scenario: Searching with the pattern "G" on sentence level
    When I run `proiel grep --level sentence 'G' ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should contain "Gallia"
    Then the output should contain "Gallos"
    Then the output should contain "Germanis"

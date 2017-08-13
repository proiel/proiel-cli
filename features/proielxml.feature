Feature: Converting to PROIEL XML

Scenario: antecedent_id references a token that will be filtered out because of its annotation status
  When I run `proiel convert proielxml --remove-not-reviewed ../../features/missing-antecedent.xml`
  Then the output should be valid

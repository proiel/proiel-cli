Feature: Converting to Proiel XML

Scenario: antecedent_id references a token that will be filtered out in because of its annotation status
  When I run `proiel convert proielxml --remove-not-reviewed ../../features/missing-antecedent.xml > a.xml && proiel validate a.xml`
  Then the output should contain "is valid"

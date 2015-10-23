Feature: Converting to text

  Scenario: Help is displayed
    When I run `proiel convert text --help`
    Then the output should contain "Usage:"

  Scenario: Presentation fields and form are converted to text
    When I run `proiel convert text ../../features/dummy-proiel-xml-2.0.xml`
    Then the output should be equal to file "features/dummy.text"

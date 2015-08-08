Feature: Project initialization

  Scenario: A project name is missing
    When I run `proiel init`
    Then the output should contain "Missing project name"

  Scenario: Help is displayed
    When I run `proiel init --help`
    Then the output should contain "Usage:"

  Scenario: A project is initialized
    When I run `proiel init something`
    Then the file "something/Gemfile" should exist
    And the file "something/myproject.rb" should exist
    And the file "something/Gemfile.lock" should exist
    And a directory named "something/vendor/proiel-treebank" should exist

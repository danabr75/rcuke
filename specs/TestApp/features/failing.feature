Feature: Visiting the index page (failing)

  Background:
    Given I go to the home page

  @failing
  Scenario: Find Ramaze text on the homepage
    Then I should not see "Rails is working correctly with this application" on the page
    And I should see "now you can start working" on the page

  @failing
  Scenario: Find Links on the homepage
    Then I should not see the link "getting started"
    Then I should see the link "introductory tutorial"
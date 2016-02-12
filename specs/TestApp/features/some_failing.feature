Feature: Visiting the index page (partial failing)

  Background:
    Given I go to the home page

  @passing
  Scenario: Find Ramaze text on the homepage
    Then I should see "Rails is working correctly with this application" on the page
    And I should see "now you can start working" on the page

  @passing
  Scenario: Find Links on the homepage
    Then I should see the link "getting started"
    Then I should see the link "introductory tutorial"

  @failing
  Scenario: Find Ramaze text on the homepage
    Then I should not see "Rails is working correctly with this application" on the page
    And I should see "now you can start working" on the page

  @failing
  Scenario: Find Links on the homepage
    Then I should not see the link "getting started"
    Then I should see the link "introductory tutorial"
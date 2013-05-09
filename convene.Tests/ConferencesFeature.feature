Feature: ConferencesFeature
	As a conference presenter
	I would like to see a list of upcoming conferences
	In order to know what to submit presentations for

Scenario: Get conferences returns no results when no data available
	Given I have the following conferences:
		| Name | Description | StartDate |
	When I GET the resource Conferences
	Then the result should contain 0 Conference resources

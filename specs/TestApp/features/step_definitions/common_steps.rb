When /^I go to the home page$/ do
  visit '/'
end

When /^I check the "([^"]+)" checkbox$/ do |check_text|
  check check_text
end

When(/^I choose the "([^"]*)" option$/) do |radio_button|
  choose radio_button
end

Given /^PENDING$/ do
  pending
end

When /^I click the "([^"]+)" link$/ do |link_text|
  click_link link_text
end

When /^I click the "([^"]+)" button$/ do |button_text|
  click_button button_text
end

Given /^PENDING: (.*)/ do |pending_message|
  pending pending_message
end

When /^I go to the url "(.*)"$/ do |url|
  visit url
end

Then /^I should( not)? see "(.*?)" on the page$/ do |should_not_be, text|
  if should_not_be
    page.should_not have_content(text)
  else
    page.should have_content(text)
  end
end

Then /^I should( not)? see the link "([^\"]*)"$/ do |should_not_be, linked_text|
  if should_not_be
    page.should_not have_css("a", :text => linked_text)
  else
    page.should have_css("a", :text => linked_text)
  end
end
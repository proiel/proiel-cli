require 'aruba/cucumber'

Then(/^the output should be equal to file "([^"]*)"$/) do |reference_file|
  expected = File.open(reference_file).read
  expect(all_commands.map(&:stdout).join("\n")).to eq(expected)
end

Then(/^the output should have (\d+) lines$/) do |n|
  expect(all_commands.map(&:stdout).join("\n").split("\n").length).to eq(n.to_i)
end

Then(/^the output should be empty$/) do
  expect(all_commands.map(&:stdout).join("\n")).to eq('')
end

Then(/^the errors should contain "([^"]*)"$/) do | pattern|
  expect(all_commands.map(&:stderr).join("\n")).to match(pattern)
end

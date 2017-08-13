require 'aruba/cucumber'
require 'proiel'

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

Then(/^the output should be valid$/) do
  file = Tempfile.new('proiel-cli-test')
  begin
    file.write(all_commands.map(&:stdout).join("\n"))
    file.close
    v = PROIEL::PROIELXML::Validator.new(file.path)
    expect(v.valid?).to eq(true)
  ensure
    file.close
    file.unlink
  end
end

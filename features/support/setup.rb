require 'aruba/cucumber'

Then(/^the output should be equal to file "([^"]*)"$/) do |reference_file|
  expected = File.open(reference_file).read
  assert_exact_output(expected, all_stdout)
end

Then(/^the output should have (\d+) lines$/) do |n|
  File.open("tmp.fil", "w").write(all_stdout)
  assert_exact_output(n, all_stdout.split("\n").length.to_s)
end

Then(/^the output should be empty$/) do
  assert_exact_output('', all_stdout)
end

Then(/^the errors should contain "([^"]*)"$/) do | pattern|
  assert_matching_output(pattern, all_stderr)
end

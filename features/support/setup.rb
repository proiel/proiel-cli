require 'aruba/cucumber'

Then(/^the output should be equal to file "([^"]*)"$/) do |reference_file|
  expected = File.open(reference_file).read
  assert_exact_output(expected, all_stdout)
end

#!/usr/bin/ruby
# givalia test cases
#
# $./run-test.rb
# $./run-test.rb -n test_send_enq_command
# $./run-test.rb -t TestClientFunction
#

require 'test/unit'

$:.unshift(File.join(File.expand_path("."), "lib"))
$:.unshift(File.join(File.expand_path("."), "test"))

test_file = "test/test_*.rb"

# Test start
Dir.glob(test_file) do |file|
    require './' + file.sub(/\.rb$/, '')
end


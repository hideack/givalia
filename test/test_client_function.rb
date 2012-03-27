require 'rubygems'
require 'json'
require 'lib/client.rb'

class TestClientFunction < Test::Unit::TestCase
    # 0. Test for invalid command.
    def test_send_invalid_command
        client = Givalia::Client.new("127.0.0.1", 12322)
        res = client.foo({:time=>2, :module=>"Sample", :params=>"parameter sample"})
        client.close

        decRes = JSON.parse(res)

        testval = "fail"
        val = decRes['response']

        assert testval==val, "JSON response invalid."
    end

    # 1. Test for ENQ command
    def test_send_invalid_parameters
        client = Givalia::Client.new("127.0.0.1", 12322)
        res = client.enq("foobar")
        client.close

        decRes = JSON.parse(res)

        testval = "fail"
        val = decRes['response']

        assert testval==val, "JSON response invalid."
    end

    def test_send_enq_command
        client = Givalia::Client.new("127.0.0.1", 12322)
        res = client.enq({:time=>2, :module=>"Sample", :params=>"parameter sample"})
        client.close

        decRes = JSON.parse(res)

        testval = "success"
        val = decRes['response']

        assert testval==val, "JSON response invalid."
    end

end


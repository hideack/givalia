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

    def test_send_stat_command
        client = Givalia::Client.new("127.0.0.1", 12322)
        res = client.enq({:time=>2, :module=>"Sample", :params=>"stat test", :key=>"stattest"})
        decRes = JSON.parse(res)

        assert decRes['response'] == "success", "Enque failed."

        res = client.stat({:key => "stattest"})
        decRes = JSON.parse(res)

        assert ((decRes['response'] == "success") or (decRes['desc']['que'])), "STAT failed." 

        sleep 3
        
        res = client.stat({:key => "stattest"})
        decRes = JSON.parse(res)

        assert ((decRes['response'] == "success") or (!decRes['desc']['que'])), "STAT failed." 
    end

    # 3. test for CANCEL command
    def test_send_cancel_command
        client = Givalia::Client.new("127.0.0.1", 12322)
        res = client.enq({:time=>2, :module=>"Sample", :params=>"cancel test", :key=>"canceltest"})
        decRes = JSON.parse(res)

        assert decRes['response'] == "success", "Enque failed."

        res = client.cancel({:key=>"canceltest"})
        decRes = JSON.parse(res)

        assert decRes['response'] == "success", "Cancel failed."

        res = client.stat({:key=>"canceltest"})
        decRes = JSON.parse(res)

        assert ((decRes['response'] == "success") and (!decRes['desc']['que'])), "Cancel process failed. (message still exists)"
        
        client.close
    end

    # 4. test for EXTEND command
    def test_send_extend_command
        client = Givalia::Client.new("127.0.0.1", 12322)
        res = client.enq({:time=>2, :module=>"Sample", :params=>"time extend test", :key=>"time_extend"})
        decRes = JSON.parse(res)
        assert decRes['response'] == "success", "Enque failed."

        res = client.ext({:key=>"time_extend", :time=>3})
        decRes = JSON.parse(res)
        assert decRes['response'] == "success", "Timeext failed."

        sleep 3

        res = client.stat({:key=>"time_extend"})
        decRes = JSON.parse(res)

        assert (decRes['response'] == "success" and decRes['desc']['que']), "Message waketime extension failed." 

        client.close
    end
end


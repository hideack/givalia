# Givalia client
# -*- coding: utf-8 -*-

require 'rubygems'
require 'json'
require 'socket'

module Givalia
    class Client
        def initialize(host, port)
            @client = TCPSocket.new(host, port)
        end

        def method_missing(action, *params)
            jobSchedule = {
                :action => action,
                :job => params[0]
            }

            command = jobSchedule.to_json
            @client.puts "#{command}\r\n"
            
            resp = ""
            resp << @client.gets

            resp
        end

        def close
            @client.close
        end
    end
end


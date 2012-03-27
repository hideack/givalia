require 'singleton'

module Givalia
    class Options
        include Singleton

        attr_accessor :master_server
        attr_accessor :daemon
        attr_accessor :main_port
        attr_accessor :sub_port
        attr_accessor :log_path

        def initialize
            @master_server = "127.0.0.1"
            @daemon    = false
            @main_port = 12322     #givalia server port
            @sub_port  = 12323     #givalia server subport (druby server)
            @log_path  = nil       #givalia log path
        end
    end
end

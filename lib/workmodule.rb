# Givalia work module (super class)

module Givalia
    class WorkModule
        attr_writer :params

        def initialize
            @params = nil
        end

        def process
        end

        def log
        end

        def run
            process
        end
    end
end

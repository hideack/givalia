#

module Givalia
    class Job
        attr_accessor :id
        attr_accessor :response
        attr_accessor :module
        attr_accessor :params
        attr_accessor :key

        def initialize
            @id = nil
            @response = false
            @module = ""
            @params = nil
            @key = nil
        end
    end
end


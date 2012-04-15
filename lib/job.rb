#

module Givalia
    class Job
        attr_accessor :id
        attr_accessor :response
        attr_accessor :module
        attr_accessor :params
        attr_accessor :key
        attr_accessor :target_worker

        def initialize
            @id = nil
            @response = false
            @module = ""
            @params = nil
            @key = nil
            @target_worker = "any"
        end
    end
end


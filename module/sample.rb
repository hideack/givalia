require File.dirname(__FILE__) + "/../lib/workmodule"

class Sample < Givalia::WorkModule

    def process 
        p "Run job sample"
        p @params
    end
end


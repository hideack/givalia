# givalia worker
require 'drb/drb'
require 'optparse'

require 'job'
require 'options'

path =  File.dirname(File.expand_path($PROGRAM_NAME))
$LOAD_PATH << path + "/../module"

module Givalia
    class Worker
        attr :options
        
        def initialize(argv)
            @options = Options.instance 
            parseArgv(argv)

            DRb.start_service
            @@ts = DRbObject.new_with_uri("druby://#{@options.master_server}:#{@options.sub_port}")
        end

        def run
            loop do
                tuple = @@ts.take(["worker", nil])

                tuple[1].each{|job|
                    @@ts.write(["report", "[worker] job start = module:#{job.module} / params:#{job.params}"])

                    begin
                        #load module
                        require job.module
                        work = Object.const_get(job.module).new

                        if !job.params.nil?
                            work.params = job.params
                        end

                        work.run

                        @@ts.write(["report", "[worker] job finished = module:#{job.module}"])

                    rescue LoadError
                        @@ts.write(["report", "[worker] module:#{job.module} load error"])

                    rescue
                        @@ts.write(["report", "[worker] raise error module:#{job.module}"])

                    end
                }
            end
        end

        def parseArgv(argv)
            optset = OptionParser.new
            optset.banner = "usage:#{File.basename($0)} [options] address"

            optset.on("-d", "--daemon") {|v|
                @options.daemon = true
            }

            optset.on("-m", "--master [HOST NAME]") {|v|
                @options.master_server = v
            }

            optset.on("-w", "--workerport [PORT]") {|v|
                @options.sub_port = v
            }

            optset.on_tail("-h", "--help", "Show this message") {
                puts optset; exit
            }

            optset.parse!(argv)
        end

        def daemon?
            @options.daemon
        end

    end
end


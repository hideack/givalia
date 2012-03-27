# Givalia server
# -*- coding: utf-8 -*-

require 'rubygems'
require 'json'
require 'eventmachine'
require 'rinda/tuplespace'
require 'optparse'
require 'logger'

require 'options'
require 'job'

module Givalia
    class Server
        attr :options

        @@ts = Rinda::TupleSpace.new
        @@jobSchedules = Hash.new 

        def initialize(argv)
            @options = Options.instance 
            parseArgv(argv)

            begin
                if @options.log_path.nil?
                    logpath = "#{File.dirname(File.expand_path($PROGRAM_NAME))}/../log/server.log"
                else
                    logpath = @options.logpath
                end

                @@logger = Logger.new(logpath)
                @@logger.progname = "givalia"
            rescue
                puts "Log file setting failed."
                exit(1)
            end
        end

        def run

            # Server <=> Worker messaging
            DRb.start_service("druby://:#{@options.sub_port}", @@ts)
            @@logger.info("[server] worker messaging server started. port=#{@options.sub_port}")

            # Work logger
            Thread.new do
                loop do
                    tup = @@ts.take(["report", nil])
                    @@logger.info(tup[1])
                end
            end

            # Server main thread
            EM.run do
                # Master server operation
                EM.start_server('localhost', @options.main_port) {|conn|
                    def conn.post_init
                    end

                    def conn.receive_data(data)
                        data.chomp!

                        begin
                            tmp = Givalia::Server.parseCommand(data)

                            action = tmp['action']
                            params = tmp['job']

                        rescue
                            @@logger.info("[server] received for invalid json parameters")
                            send_data(Givalia::Server.generateResponse(false, 'invalid json parameters.'))
                            return
                        end

                        @@logger.info("[server] action:#{action} / module:#{params['module']}")

                        case action
                        when "enq"
                            waketime = (Time.now + params['time']).to_i

                            job = Givalia::Job.new
                            job.module = params['module']
                            job.params = params['params']

                            if @@jobSchedules.has_key?(waketime)
                                @@jobSchedules[waketime] << job 
                            else
                                @@jobSchedules[waketime] = [job]
                            end

                            send_data(Givalia::Server.generateResponse(true, 'enque successfull.'))
                        else
                            send_data(Givalia::Server.generateResponse(false, 'Invalid command.'))
                        end
                    end

                    def conn.unbind
                        @@logger.info("[server] disconnected from server")
                    end
                }

                @@logger.info("[server] givalia server started. port=#{@options.main_port}")

                # Worker controller 
                EM.add_periodic_timer(1) do
                    waketime = Time.now.to_i
                    if @@jobSchedules.has_key?(waketime)
                        jobs = @@jobSchedules[waketime]
                        @@ts.write(["worker", jobs])

                        @@jobSchedules.delete(waketime)
                    end
                end

            end
        end

        def parseArgv(argv)
            optset = OptionParser.new
            optset.banner = "usage:#{File.basename($0)} [options] address"

            optset.on("-d", "--daemon") {|v|
                @options.daemon = true
            }

            optset.on("-p", "--mainport [PORT]") {|v|
                @options.main_port = v
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

        def Server.parseCommand(data)
            decJson = JSON.parse(data)

            case decJson['action']
            when "enq"
                if decJson['job']['time'].nil? or decJson['job']['module'].nil?
                    raise "ENQ command needs parameters"
                end

                decJson
            else
                raise "No definition action called."
            end
        end

        def Server.generateResponse(resFlg, resMsg)
            response = resFlg ? "success" : "fail"
            resJson = {:response => response, :desc => resMsg}.to_json

            "#{resJson}\n"
        end
    end
end


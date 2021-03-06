require 'rubygems'
require 'bundler/setup'
require 'base64'
require 'dalli'
require 'streamio-ffmpeg'
require_relative 'lib/omx'

CACHE = Dalli::Client.new('127.0.0.1:11211')

EM.run {

  @controller = Omx::Controller.new

  serv = EM::WebSocket.run(host: '0.0.0.0', port: ENV['SOCKET_PORT']) do |server|

    deliver = lambda {|hash| server.send Oj.dump(hash) }

    server.onmessage do |msg|
      deliver.call begin
        res = @controller.react_to Oj.strict_load msg
        # res might return some results to the client
        res.nil? ? @controller.as_json : res
      rescue Exception => e
        {'error' => e.message}
      end
    end

    calculate_file_length = proc {
      sleep 3 # allows the omxplayer instance to launch
      filename = Omx::Status.new.filename
      puts "Calculating file length for #{filename}"
      begin
        duration = filename.empty? ? nil : FFMPEG::Movie.new(filename).duration
        if duration && filename
          CACHE.set Base64.encode64(filename), duration
          puts "Setting duration for #{filename} with #{duration}"
        end
        duration
      end
    }

    EM.add_periodic_timer(1) do
      EM.defer calculate_file_length if @controller.play_next_if_needed
      deliver.call @controller.as_json
    end


  end

} if ENV['SOCKET_PORT']
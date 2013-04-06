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
        @controller.react_to Oj.strict_load msg
        puts @controller.as_json
        @controller.as_json
      rescue Exception => e
        {'error' => e.message}
      end
    end

    calculate_file_length = proc {
      #filename = "/media/zeus/download/Family.Guy.S01E02.NoShit.EZ.TV.mp4"
      filename = Omx::Status.reload!.filename
      duration = FFMPEG::Movie.new(filename).new.duration
      CACHE.set Base64.encode64(filename), duration#file.duration
      duration
    }

    EM.add_periodic_timer(1) do
      EM.defer calculate_file_length if @controller.play_next_if_needed
      deliver.call @controller.as_json
    end


  end

} if ENV['SOCKET_PORT']
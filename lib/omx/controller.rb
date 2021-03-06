require 'eventmachine'
require 'em-websocket'
require 'oj'

require_relative '../omx/status'

module Omx
  class Controller

    attr_reader :q, :output_mode

    def initialize(queue=[], opts={})
      @q = queue
      @output_mode = opts[:output_mode] || 'hdmi'
      @player = opts[:player] || Omx::Player.new

      @q.instance_eval {
        alias :orig_append :<<

        def <<(obj)
          orig_append parse_stream_type(obj)
        end

        def parse_stream_type(url)
          return Omx::Stream::Youtube.url_from(url) if url =~ /youtube.com/
          url
        end
      }
    end

    def as_json
      {
        'queue' => @q,
        'output_mode' => @output_mode,
        'now_playing' => Omx::Status.new.to_h
      }
    end

    def react_to(opts)

      # Try and run the action on this controller first.
      if respond_to? opts['action'].to_s
        return send opts['action'], opts['option']
      end

      # Run commands on the player itself
      if @player.respond_to? opts['action'].to_s
        return if @player.send opts['action']
      end

      # Finally, try and run it directly from the array
      if @q.respond_to? opts['action'].to_s
        return if @q.send(opts['action'], opts['filename']) && @q.compact!
      end

    end

    def clear(*args)
      @q.clear
    end

    def change_output(mode)
      {'mode' => "#{@output_mode = mode}"}
    end

    def search(file)
      {'results' => Omx::Search.new.run(file)}
    end

    def play_next_if_needed
      if @q.any? && !Omx::Status.new.playing?
        Omx::Player.new.open({filename: @q.shift, audio_out: @output_mode})
      end
    end

  end
end
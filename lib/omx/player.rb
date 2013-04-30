module Omx
  class Player
    include KeyboardShortcuts

    PIPE = '/tmp/omxpipe'

    def initialize
      mkfifo
    end

    def open(opts={})
      opts = default_options.merge(opts)
      safe_execute unix_command_with(opts)
      start
    end

    private

      def unix_command_with(opts)
        %w[omxplayer].tap do |args|
          # Audio device =~ /hdmi|local/
          args << "--adev #{opts[:audio_out]}"
          # Start position in seconds
          args << "--pos #{opts[:start_pos]}"
          args << "\"#{opts[:filename]}\""
          args << "< #{PIPE} &"
        end.join ' '
      end

      def mkfifo
        safe_execute "mkfifo #{PIPE}" unless File.exists?(PIPE)
      end

      def send_to_pipe(command)
        safe_execute "echo -n #{command} > #{PIPE} &"
      end

      def default_options
        {
          audio_out: 'hdmi',
          start_pos: 0,
        }
      end

      def safe_execute(command)
        fork do
          exec command
        end
      end

  end
end
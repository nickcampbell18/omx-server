module Omx
  class Status
    extend Omx::TimeCalculator
    class << self

      def now_playing
        @r ||= begin
          results = status_pattern.match(status_command)
          # [time, audio_out, filename]
          results ? results.captures : [nil, nil, nil]
        end
      end

      def running_time
        now_playing[0]
      end

      def audio_out
        now_playing[1]
      end

      def filename
        now_playing[2].gsub /"/, ''
      end

      def playing?
        now_playing.compact.any?
      end

      def reload!
        remove_instance_variable :@r if @r
        self
      end

      def to_h
        playing? ? {
          'running_time' => running_time,
          'audio_out'    => audio_out,
          'filename'     => filename,
          'percentage'   => percentage,
          'file_length'  => file_length
        } : 'not playing'
      end

      def percentage
        ps_time_in_secs(running_time) / file_length
      end

      def file_length
        CACHE.get Base64.encode64(filename) || 1.0
      end

      private

        def status_pattern
          /([\d:.]+) \S*omxplayer\S* --adev (\S+).*("\S+") < \S+/
        end

        def status_command
          # The [/] excludes self matches http://serverfault.com/q/367921
          '12:32 /usr/bin/omxplayer.bin --adev hdmi "/media/zeus/download/Family.Guy.S01E02.NoShit.EZ.TV.mp4" < /tmp/etc'
          #{}`ps ax -o etime,args | grep [/]usr/bin/omxplayer.bin`
        end

    end
  end
end
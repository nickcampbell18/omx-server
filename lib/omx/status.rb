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
        ps_time_in_secs now_playing[0]
      end

      def audio_out
        now_playing[1]
      end

      def filename
        now_playing[2].to_s.gsub /"/, ''
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
        ((running_time / file_length) * 100).round(2)
      end

      def file_length
        CACHE.get(Base64.encode64(filename)).to_f || 1.0
      end

      private

        def status_pattern
          /([\d:.]+) \S*omxplayer\S* --adev (\S+) --pos \d+ ("?\S+"?)/
        end

        def status_command
          # The [/] excludes self matches http://serverfault.com/q/367921
          #'12:32 /usr/bin/omxplayer.bin --adev hdmi "/media/zeus/download/Family.Guy.S01E02.NoShit.EZ.TV.mp4" < /tmp/etc'
          `pgrep -lf "omxplayer.bin" | grep [/]usr/bin/omxplayer.bin`
        end

    end
  end
end
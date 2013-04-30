module Omx
  class Status
    include Omx::TimeCalculator

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
      return 0 if file_length == 0.0
      ((running_time / file_length) * 100).round(2)
    end

    def file_length
      @len ||= CACHE.get(Base64.encode64(filename)).to_f
    end

    private

      def status_pattern
        /([\d:.]+) \S*omxplayer\S* --adev (\S+) --pos \d+ ("?.*"?)/
      end

      def status_command
        # The [..] excludes self matches http://serverfault.com/q/367921
        # 03:37 /usr/bin/omxplayer.bin --adev hdmi --pos 0 /media/zeus/videos/television/Arrested Development/Arrested Development - [01x02] - Top Banana.avi
        # process_ids is a multiline list of pids
        pids = `pgrep "[o]mxplayer.bin"`
        # pgrep is much faster than ps, and sed removes the top line
        pids.empty? ? '' : `echo '#{pids}' | xargs ps -o etime,args p | sed 1d`
      end

  end
end
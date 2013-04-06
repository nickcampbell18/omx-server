module Omx::TimeCalculator

  def parse_ps_timestamp(str)
    # Parses 01:32
    # or 01:56:43
    hours, mins, secs = str.gsub(/:/, '').rjust(6,'0').scan(/../).map(&:to_i)
  end

  def ps_time_in_secs(str)
    hours, mins, secs = parse_ps_timestamp(str)
    hours * 60 * 60 + mins * 60 + secs
  end

end
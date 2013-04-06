module Omx
  VERSION = '1.0.0'
end
%w[ keyboard_shortcuts time_calculator player status controller].each do |file|
  require_relative "omx/#{file}"
end
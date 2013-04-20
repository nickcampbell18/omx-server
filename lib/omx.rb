module Omx
  VERSION = '1.0.0'
end
%w[ keyboard_shortcuts time_calculator player status controller search].each do |file|
  require_relative "omx/#{file}"
end
%w[ youtube].each do |stream|
  require_relative "omx/stream/#{stream}"
end
require_relative '../spec_helper'

describe "Omx::TimeCalculator" do

  before :all do
    @obj = Object.new
    @obj.extend Omx::TimeCalculator
  end

  it 'can parse minutes from ps time' do
    hours, mins, secs = @obj.parse_ps_timestamp '05:32'
    hours.should == 0
    mins.should == 5
    secs.should == 32
  end

  it 'can parse full ps time' do
    hours, mins, secs = @obj.parse_ps_timestamp '01:56:43'
    hours.should == 1
    mins.should == 56
    secs.should == 43
  end

  it 'can get ps time in secs' do
    @obj.expects(:parse_ps_timestamp).returns [0,43,12]
    @obj.ps_time_in_secs('43:12').should == 2592.0
  end

end
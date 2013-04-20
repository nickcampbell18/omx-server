require_relative '../spec_helper'

describe Omx::Search do

  before :all do
    @search = Omx::Search.new
  end

  describe 'input parsing' do

    it 'should sanitize dangerous characters' do
      res = @search.send(:tokenize, 'ABC!@#$%123^&*(')
      res.should == ['ABC123']
    end

    it 'should accept alphabet numerical and dots' do
      @search.send(:tokenize, 'AB cd 56 .mp3').should == %w{ AB cd 56 .mp3}
    end

    it 'should append and prepend an asterix' do
      arr = ['file', 'name.mp4']
      @search.send(:glob,arr).should == '*file*name.mp4*'
    end

  end

  describe 'finding a file' do

    it 'should find a file' do
      @search.stubs(:locate).returns ['/dir/file.mp4']
      %w{/dir/file.mp4}.should == @search.run('file.mp4')
    end

  end

end
# Tests the functionality of the command line
# Non git functions
# ls, cd, mkdir, touch, echo, mv

require 'selenium-webdriver'
require 'json'
require_relative "interaction_helper.rb"

describe "GitSimulation" do
  include BrowserShortcuts

  before :each do
    @chrome = Selenium::WebDriver.for :chrome
    @chrome.get "http://davidpmah.com/test/gitsimulation"
    @browser = @chrome
    set_default_environment(@chrome)
  end

  after :each do
    @chrome.close
  end
  describe "ls" do
    it "should read from the local _entries list" do
      run('ls')
      @chrome.find_element(:id, "tl19").text.should == "file39 file42 dir9001"
    end
  end

  describe 'touch' do
    it "should create all of these files in the local path" do
      run('touch a b c')
      run('ls')
      fs = retrieve_file_system()
      fs[:_entries] && ['a', 'b', 'c'] == ['a', 'b', 'c']
      fs[:a].should == {:_type => 'file', :text => ""}
      fs[:b].should == {:_type => 'file', :text => ""}
      fs[:c].should == {:_type => 'file', :text => ""}
    end
  end
end

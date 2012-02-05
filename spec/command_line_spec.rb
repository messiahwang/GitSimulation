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
    set_environment(@chrome)
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

  describe 'cd' do
    before :each do
      set_environment(@chrome, :extended)
    end

    it "should switch relative directories" do
      run("cd dir9001")
      execute("return window.current_location").should == "/dir9001"
    end

    it "should follow paths with /" do
      run("cd dir9001/d1")
      execute("return window.current_location").should == "/dir9001/d1"
    end

    it "should respond if the directory doesn't exist" do
      run("cd garpley")
      @chrome.find_element(:id, "tl19").text.should == "cd: garpley: No such file or directory"
      execute("return window.current_location").should == ""
    end

    it "should respond if the user is trying to interact with a file" do
      run("cd file39")
      @chrome.find_element(:id, "tl19").text.should == "cd: file39: Not a directory"
      execute("return window.current_location").should == ""
    end

    it "should follow pure paths if the input starts with a /" do
      execute(%Q[window.current_location = "/dir9001/d1"])
      run("cd /dir9001/d2")
      execute("return window.current_location").should == "/dir9001/d2"
    end
  end

  describe "echo" do
    it "should report to standard output" do
      run("echo apple")
      @chrome.find_element(:id, "tl19").text.should == "apple"
    end

    it "should annihilate spaces" do
      run("echo apple             turtle")
      @chrome.find_element(:id, "tl19").text.should == "apple turtle"
    end
  end

  describe "mv" do
    it "should rename the asked file" do
      run("mv file39 garpley")
      fs = retrieve_file_system
      fs[:_entries].include?('file39').should_not == true
      fs[:garpley][:_text].should == "file39"
      fs[:_entries].include?('garpley').should == true
    end
  end
end

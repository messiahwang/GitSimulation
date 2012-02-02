# Tests the functionality of the command line
# Non git functions
# ls, cd, mkdir, touch, echo, mv

require 'selenium-webdriver'
require 'json'

def generate_default_filesystem
  {
    "" => {
      :_type => 'dictionary',
      :_entries => ['39', '42', '9001']
    }
  }.to_json
end

def set_default_environment(browser)
  browser.execute_script(%Q[window.file_system = #{generate_default_filesystem}])
  browser.execute_script(%Q[window.current_location = ""])
end

def run_command(browser, command)
  browser.keyboard.send_keys(command)
  browser.keyboard.send_keys(:enter)
end

describe "GitSimulation" do

  def run(command)
    run_command(@chrome, command)
  end

  before :each do
    @chrome = Selenium::WebDriver.for :chrome
    @chrome.get "http://davidpmah.com/test/gitsimulation"
    set_default_environment(@chrome)
  end

  after :each do
    @chrome.close
  end
  describe "ls" do
    it "should read from the local _entries list" do
      run('ls')
      @chrome.find_element(:id, "tl19").text.split(" ").should == ['39', '42', '9001']
    end
  end

  describe 'touch' do
    it "should create all of these files in the local path" do
      run('touch a b c')
      run('ls')
      @chrome.find_element(:id, "tl19").text.split(" ").should == ['39', '42', '9001', 'a', 'b', 'c']
    end
  end
end

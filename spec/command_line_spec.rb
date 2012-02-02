# Tests the functionality of the command line
# Non git functions
# ls, cd, mkdir, touch, echo, mv

require 'selenium-webdriver'

describe "GitSimulation" do
  before :each do 
    @chrome = Selenium::WebDriver.for :chrome
    @chrome.get "http://davidpmah.com/test/gitsimulation"
  end

  after :each do
    @chrome.close
  end
  describe "ls" do
    it "should read from the local _entries list" do
      @chrome.execute_script(%Q[window.file_system = {"":
                                                        {
                                                         "_type"   : "directory",
                                                         "_entries": ['39', '42', '9001']
                                                        }
                                                     }])
      @chrome.execute_script(%Q[window.current_location = ""])
      @chrome.keyboard.send_keys("ls")
      @chrome.keyboard.send_keys(:enter)
      @chrome.find_element(:id, "tl19").text.split(" ").should == ['39', '42', '9001']
    end
  end
end

# Tests the functionality of the command line
# Non git functions
# ls, cd, mkdir, touch, echo, mv

require 'selenium-webdriver'
require 'json'
require_relative 'interaction_helper.rb'
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

  describe "linebreaks" do
    it "shouldn't linebreak at all if there's too few things" do
      sleep 2
      run("ls")
      sleep 5
      @chrome.find_element(:id, "tl19").text.split(" ").should == ['39', '42', '9001', 'a', 'b', 'c']
      run('touch 39 42 9001 a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9')
      run("ls")
      @chrome.find_element(:id, "tl19").text.split(" ").should == ['39', '42', '9001', 'a', 'b', 'c',
        'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    end

    it "should linebreak with one letter too many" do
      run('touch 39 42 9001 a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 1')
      run("ls")
      @chrome.find_element(:id, "tl18").text.split(" ").should == ['39', '42', '9001', 'a', 'b', 'c',
        'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9']
      @chrome.find_element(:id, "tl19").text.split(" ").should == ['1']
    end

  end
end

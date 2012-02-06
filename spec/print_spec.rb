# Tests the functionality of the command line
# Non git functions
# ls, cd, mkdir, touch, echo, mv

require_relative 'interaction_helper.rb'

describe "GitSimulation" do
  include BrowserShortcuts

  before :each do
    prepare_web_driver
  end

  after (:all) do
    close_web_driver
  end

  # This will break if the terminal size is changed.. 
  # Not worth the engineering time to generalize this now!
  describe "linebreaks" do
    it "shouldn't linebreak at all if there's too few things" do
      run('touch a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3')
      run("ls")
      @chrome.find_element(:id, "tl19").text.should == "file39 file42 dir9001 a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3"
    end

    it "should linebreak with one letter too many" do
      run('touch a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4')
      run("ls")
      @chrome.find_element(:id, "tl18").text.should == "file39 file42 dir9001 a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3"
      @chrome.find_element(:id, "tl19").text.should == "4"
    end

  end
end

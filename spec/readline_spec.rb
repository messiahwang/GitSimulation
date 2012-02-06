require_relative "interaction_helper.rb"

describe "readline" do
  include BrowserShortcuts

  before :each do
    prepare_web_driver
  end

  after(:all) do
    close_web_driver
  end

  describe "left/right arrows" do
    it "should let me move left" do
      send_keys("12345")
      send_keys(:left)
      send_keys(:backspace)
      get_element_text('tl20').should == "$ 1235"
    end

    it "should let me move left, then back right" do
      send_keys("12345")
      send_keys(:left)
      send_keys(:left)
      send_keys(:right)
      send_keys(:left)
      send_keys(:right)
      send_keys(:backspace)
      get_element_text('tl20').should == "$ 1235"
    end
  end
end

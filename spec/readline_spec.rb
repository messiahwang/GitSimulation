require_relative "interaction_helper.rb"

describe "readline" do
  include BrowserShortcuts

  def get_readline_data
    @readline_data = JSON.parse(execute("return JSON.stringify(window.readline)"))
  end

  before :each do
    prepare_web_driver
  end

  after(:all) do
    close_web_driver
  end

  describe "index" do
    it "should add text at the index spot" do
      send_keys("12345")
      execute("window.readline['index'] = 1")
      send_keys("a")
      get_readline_data
      @readline_data['input'].should == "1a2345"
      @readline_data['index'].should == 2
    end

    it "should remove text at the index spot" do
      send_keys("12345")
      execute("window.readline['index'] = 1")
      send_keys(:backspace)
      get_readline_data
      @readline_data['input'].should == "2345"
      @readline_data['index'].should == 0
    end

    it "shouldn't be able to remove if index is 0" do
      send_keys("12345")
      execute("window.readline['index'] = 0")
      send_keys(:backspace)
      get_readline_data
      @readline_data['input'].should == "12345"
      @readline_data['index'].should == 0
    end
  end

  describe "left/right arrows" do
    it "should let me move left" do
      send_keys("12345")
      send_keys(:left)
      get_readline_data
      @readline_data['index'].should == 4
    end

    it "should let me move left, then back right" do
      send_keys("12345")
      send_keys(:left)
      send_keys(:left)
      send_keys(:right)
      send_keys(:left)
      get_readline_data
      @readline_data['index'].should == 3
    end

    it "should not let me move past the left border" do
      send_keys("12345")
      9.times { send_keys(:left) }
      get_readline_data
      @readline_data['index'].should == 0
    end

    it "should not let me move past the right border" do
      send_keys("12345")
      9.times { send_keys(:right) }
      get_readline_data
      @readline_data['index'].should == 5
    end
  end
end

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

    it "should reset after sending the command in" do
      send_keys("12345")
      send_keys(:enter)
      get_readline_data
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

  describe "autocomplete" do
    it "should autocomplete my text if theres only one option" do
      send_keys("file3")
      send_keys(:tab)
      get_readline_data
      @readline_data['input'].should == "file39"
    end

    it "should autocomplete my text with a command prepending it" do
      send_keys("cd file3")
      send_keys(:tab)
      get_readline_data
      @readline_data['input'].should == "cd file39"
    end

    it "should autocomplete my most current argument" do
      send_keys("asd sdf sdf sdf file3")
      send_keys(:tab)
      get_readline_data
      @readline_data['input'].should == "asd sdf sdf sdf file39"
    end

    it "should not autocomplete if there are multiple options" do
      send_keys("file")
      send_keys(:tab)
      get_readline_data
      @readline_data['input'].should == "file"
    end
  end
end

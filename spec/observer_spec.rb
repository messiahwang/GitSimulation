require_relative "interaction_helper.rb"

describe "Observer" do
  include BrowserShortcuts
  before :each do
    tutorial = [{
                  'text'  => "example garpley1",
                  'rules' => ["exists file39"]
                },
                {
                  'text'  => "example garpley2",
                  'rules' => ["exists file123"]
                },
                {
                  'text'  => "example garpley3",
                  'rules' => ["ran_command file39"]
                },

    ].to_json
    prepare_web_driver(:tutorial => tutorial)
  end

  after :all do
    close_web_driver
  end

  describe "initializing the tutorial" do
    it "should start from the first rule" do
      get_element_text('instructions').should == 'example garpley1'
    end
  end
end


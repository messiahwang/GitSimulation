require_relative "interaction_helper.rb"

describe "Observer" do
  include BrowserShortcuts
  before :each do
    tutorial = [{
                  'text'  => "example garpley1",
                  'rules' => ["exists /file38"]
                },
                {
                  'text'  => "example garpley2",
                  'rules' => ["ran_command git init"]
                },
                {
                  'text'  => "example garpley3",
                  'rules' => ['has_text /file38 turtles turtles']
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

    it "should transition to the next rule once that file exists" do
      run('touch file38')
      sleep(0.6)
      get_element_text('instructions').should == 'example garpley2'
    end

    it "should move me to the next rule using nextRule" do
      execute(%Q[window.observer.nextRule()])
      get_element_text('instructions').should == 'example garpley2'
    end

    it "should transition to the next rule once that command is run" do
      execute(%Q[window.observer.nextRule()])
      run('git init')
      get_element_text('instructions').should == 'example garpley3'
    end

    # it "should transition to the next rule once that text is noticed to have the content"
    #   execute(%Q[window.observer.nextRule()])
    #   run('git init')
    #   get_element_text('instructions').should == 'example garpley3'
    # end
  end
end


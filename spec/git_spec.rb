# git functions
# init, branch, checkout

require_relative 'interaction_helper.rb'

describe "Git Spec" do
  include BrowserShortcuts

  before :each do
    prepare_web_driver
  end

  after (:all) do
    close_web_driver
  end

  describe "git init" do
    it "should turn create a .git directory" do
      run('git init')
      retrieve_file_system
      @fs[:".git"].should_not == nil
      @fs[:_entries].include?('.git').should == true
    end
  end
end

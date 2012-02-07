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
    it "should turn create a .git directory with master referenced in branches" do
      run('git init')
      retrieve_file_system
      @fs[:".git"].should_not == nil
      @fs[:_entries].include?('.git').should == true
      branch_path = @fs[:".git"][:branches]
      branch_path[:_branches].include?('master').should == true
      branch_path[:master].should_not == nil
      branch_path[:_current].should == "master"
    end
  end

  describe "git branch" do
    before :each do 
      execute(%Q[window.file_system['']['.git'] = {}])
      execute(%Q[window.file_system['']['.git']['branches'] = {}])
      execute(%Q[window.file_system['']['.git']['branches']['current'] = 'master'])
      execute(%Q[window.file_system['']['.git']['branches']['master'] = {}])
      execute(%Q[window.file_system['']['.git']['branches']['dev'] = {}])
      execute(%Q[window.file_system['']['.git']['branches']['_entries'] = ['.', '..', 'master', 'dev']])
      execute(%Q[window.file_system['']['.git']['branches']['_branches'] = ['master', 'dev']])
    end

    it "should list the available branches" do
      run('git branch')
      get_element_text('tl18').should == "* master"
      get_element_text('tl19').should == "  dev"
    end

    it "should star the current branch" do
      run('git branch')
      execute(%Q[window.file_system['']['.git']['branches']['current'] = "dev"])
      get_element_text('tl18').should == "  master"
      get_element_text('tl19').should == "* dev"
    end

    it "should create a new branch" do
      run('git branch garpley')
      retrieve_file_system
      branch_path = @fs[:".git"][:branches]
      branch_path[:_branches].include?('garpley').should == true
      branch_path[:garpley].should_not == nil
    end

    it "should not erase a preexisting branch" do
      entry_count = retrieve_file_system[:".git"][:branches][:_branches].size
      run('git branch dev')
      retrieve_file_system
      branch_path = @fs[:".git"][:branches]
      branch_path[:_branches].size.should == entry_count
      get_element_text('tl19').should == "fatal: A branch named 'dev' already exists."
    end
  end

  describe "git checkout" do
    it "should switch into the given branch" do
      run('git checkout dev')
      retrieve_file_system
      branch_path = @fs[:".git"][:branches]
      branch_path[:current] == "dev"
    end

    it "should report error if it cannot switch" do
      run('git checkout garpley')
      retrieve_file_system
      branch_path = @fs[:".git"][:branches]
      branch_path[:current].should == "master"
      get_element_text('tl19').should == %Q[error: pathspec 'garpley' did not match any file(s) known to git.]
    end
  end
end

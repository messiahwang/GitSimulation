require 'json'

def generate_default_filesystem
  {
    "" => {
      :_type     => 'dictionary',
      :_entries  => ['file39', 'file42', 'dir9001'],
      :file39  => {:_type => "file", :_text => ""},
      :file42  => {:_type => "file", :_text => ""},
      :dir9001 => {:_type => "directory", :_entries => []}
    }
  }.to_json
end

def set_default_environment(browser)
  browser.execute_script(%Q[window.file_system = #{generate_default_filesystem}])
  browser.execute_script(%Q[window.current_location = ""])
end

def run_command(browser, command)
  browser.keyboard.send_keys(command)
  browser.keyboard.send_keys(:enter)
end


module BrowserShortcuts
  def run(command)
    run_command(@browser, command)
  end

  def execute(script)
    @browser.execute_script(script)
  end

  def retrieve_file_system
    JSON.parse(@browser.execute_script(%Q[return fsStringify();]), :symbolize_names => true)
  end
end

require 'selenium-webdriver'
require 'json'

def get_chrome
  $chrome ||= Selenium::WebDriver.for :chrome
end

def generate_default_filesystem
  {
    "" => {
      :_type     => 'directory',
      :_entries  => ['file39', 'file42', 'dir9001'],
      :file39  => {:_type => "file", :_text => "file39"},
      :file42  => {:_type => "file", :_text => "file42"},
      :dir9001 => {:_type => "directory", :_entries => []}
    }
  }
end

def generate_extended_filesystem
 fs = generate_default_filesystem
 d  = fs[""][:dir9001]
 d['_entries'] = ['d1', 'd2', 'f1']
 d[:d1] = {:_type => "directory", :_entries => []}
 d[:d2] = {:_type => "directory", :_entries => []}
 d[:f1] = {:_type => "file", :_text => ""}
 fs
end

def set_default_environment(browser)
  browser.execute_script(%Q[window.file_system = #{generate_default_filesystem.to_json}])
  browser.execute_script(%Q[window.current_location = ""])
end

def set_extended_environment(browser)
  browser.execute_script(%Q[window.file_system = #{generate_extended_filesystem.to_json}])
  browser.execute_script(%Q[window.current_location = ""])
end

def set_environment(browser, type = :default)
  if type == :default
    set_default_environment(browser)
  else
    set_extended_environment(browser)
  end
end

def run_command(browser, command)
  sleep 0.02
  browser.keyboard.send_keys(command)
  browser.keyboard.send_keys(:enter)
end


module BrowserShortcuts

  def run(command)
    run_command(@browser, command)
  end

  def send_keys(keys)
    @browser.keyboard.send_keys(keys)
    sleep 0.02
  end

  def execute(script)
    @browser.execute_script(script)
  end

  def retrieve_file_system
    @fs = JSON.parse(@browser.execute_script(%Q[return fsStringify();]), :symbolize_names => true)
  end

  def get_element_text(id)
    @browser.find_element(:id, id).text
  end

  def prepare_web_driver
    @chrome = get_chrome
    @chrome.get "http://davidpmah.com/test/gitsimulation"
    @browser = @chrome
    set_environment(@chrome)
  end

  def close_web_driver
    $chrome.close
    $chrome = nil
  end
end

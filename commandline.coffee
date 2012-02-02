$(document).ready(() ->
  prepareFileSystem()
  prepareKeyListener()
  prepareVisualConsole()
)

# --------------- File System Stuff -------------

# A file system object is a directory or a file
# that is indicated by the _type key
# a file has text
prepareFileSystem = () ->
  window.file_system =
    '/':
      _type: 'directory'
      _entries:['.', '..', 'home']
      home:
        _type: 'directory'
        _entries:['.', '..', 'bob']
        bob:
          _type: 'directory'
          _entries:['.', '..', 'a', 'b', 'c']
          a:
            _type: 'file'
          b:
            _type: 'file'
          c:
            _type: 'file'
  window.current_location = "/home/bob"
  # Makes all . point to the same directory
  # and makes all .. point to the parent directory
  crawl(window.file_system['/'], '/', (dir, dirname, entry) ->
    if entry == '.'
      dir[entry] = dir
    if dir[entry]['_type'] == 'directory'
      dir[entry]['..'] = dir
  )


# Traverse the entire file system, applying the
# given action function to all items
crawl = (current_dir = window.file_system['/'], current_name, action = null) ->
  entries = current_dir['_entries']
  for entry in entries
    console.log(entry)
    action(current_dir, current_name, entry) if action != null
    continue_crawl = current_dir[entry] != undefined and current_dir[entry]['_type'] == 'directory'
    continue_crawl = continue_crawl and current_dir[entry] != current_dir
    continue_crawl = continue_crawl and current_dir[entry][current_name] != current_dir
    crawl(current_dir[entry], entry, action) if continue_crawl

window.crawl = crawl


accessDirectory = (pathname) ->
  paths = pathname.split("/")
  paths.shift()
  current_spot = window.file_system['/']
  for path in paths
    current_spot = current_spot[path]
  current_spot

# --------------- User Input Stuff -------------
prepareVisualConsole = () ->
  window.current_input = ""
  updateCurrentInput()

prepareKeyListener = () ->
  $(document).keypress((e) ->
    handleKeyPress(e)
  )

  $(document).keydown((e) ->
    if RESERVED_KEYS[e.keyCode]
      handleKeyPress(e)
      return false
  )

handleKeyPress = (e) ->
  reserved = false
  keyCode = e.keyCode
  if RESERVED_KEYS[keyCode]
    handleReservedKey(keyCode)
  else
    injectToInput(String.fromCharCode(keyCode))

injectToInput = (character) ->
  window.current_input += character
  updateCurrentInput()

updateCurrentInput = () ->
  ps1 = window.current_location
  $('#tl20').text("#{ps1}$ #{window.current_input}")

handleReservedKey = (keyCode) ->
  RESERVED_KEYS[keyCode]()

# Individual functions for each reserved key
inputBackspace = () ->
  current = window.current_input
  window.current_input = current.substring(0, current.length - 1)
  updateCurrentInput()

inputEnter = () ->
  command = window.current_input
  window.current_input = ""
  runCommand(command)
  updateCurrentInput()

RESERVED_KEYS =
  8:  inputBackspace
  13: inputEnter
window.reserved = RESERVED_KEYS

## -------- End of User Input Stuff --------------

#-------------- Command stuff
print = (message) ->
  bottom = $('#tl19')
  bottom.text(bottom.text() + message)

runCommand = (command) ->
  shiftOutput()
  command = COMMANDS[command]
  command() if(command != undefined)

runCommandls = () ->
  current_dir = window.current_location
  dir = accessDirectory(current_dir)
  for entry in dir['_entries']
    console.log(entry)
    print("#{entry} ")

COMMANDS =
  ls: runCommandls

shiftOutput = () ->
  for i in [1..18]
    do (i) ->
      previous = $("#tl#{i + 1}").text()
      $("#tl#{i}").text(previous)
  $('#tl19').text("")


# Skip to sections of this document by searching
# [File] for the handling of the pseudo file system
# [Input] for the handling of user keyboard input
# [Command] for operations involving commands that a user runs
#
$(document).ready(() ->
  prepareFileSystem()
  prepareKeyListener()
  prepareVisualConsole()
)

# --------------- [File] System Stuff -------------

# A file system object is a directory or a file
# Meta deta of an item is lead by _
# _type => 'directory' | 'file'
# a directory has _entries and links to other items
# a file has text
prepareFileSystem = () ->
  window.file_system =
    '':
      _type: 'directory'
      _entries:['.', '..', 'home']
      home:
        _type: 'directory'
        _entries:['.', '..', 'bob']
        bob:
          _type: 'directory'
          _entries:['.', '..', 'example_file_1', 'example_file_2', 'example_directory_1']
          example_file_1:
            _type: 'file'
            text: ""
          example_file_2:
            _type: 'file'
            text: ""
          example_directory_1:
            _type: 'directory'
            _entries: ['.', '..']
  window.current_location = "/home/bob"
  setCurrentAndParentReferences()

# Makes all . point to the same directory
# and makes all .. point to the parent directory
setCurrentAndParentReferences = () ->
  window.file_system['']['home']['..'] = window.file_system['/']
  crawl(window.file_system[''], '', (dir, dirname, entry) ->
    if entry == '.'
      dir[entry] = dir
    if dir[entry]['_type'] == 'directory'
      false
      dir[entry]['..'] = dir if dir[entry]['..'] == undefined
  )



# Traverse the entire file system, applying the
# given action function to all items
crawl = (current_dir = window.file_system[''], current_name, action = null) ->
  entries = current_dir['_entries']
  for entry in entries
    action(current_dir, current_name, entry) if action != null
    continue_crawl = current_dir[entry] != undefined and current_dir[entry]['_type'] == 'directory'
    continue_crawl = continue_crawl and current_dir[entry] != current_dir
    continue_crawl = continue_crawl and current_dir[entry][current_name] != current_dir
    crawl(current_dir[entry], entry, action) if continue_crawl

window.crawl = crawl


accessDirectory = (pathname) ->
  paths = pathname.split("/")
  paths.shift()
  current_spot = window.file_system['']
  for path in paths
    current_spot = current_spot[path]
  current_spot

window.accessDirectory = accessDirectory


# --------------- User [Input] Stuff -------------

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
  input_text = substituteSpaces(retrieve_input_line())
  $('#tl20').html(input_text)

substituteSpaces = (input) ->
  input.replace(/\ /g, "&nbsp;")

handleReservedKey = (keyCode) ->
  RESERVED_KEYS[keyCode]()

# Individual functions for each reserved key
inputBackspace = () ->
  current = window.current_input
  window.current_input = current.substring(0, current.length - 1)
  updateCurrentInput()

inputEnter = () ->
  printLine(extract_input_line())
  command = extract_current_input()
  runCommand(command)
  updateCurrentInput()

RESERVED_KEYS =
  8:  inputBackspace
  13: inputEnter
window.reserved = RESERVED_KEYS

## -------- End of User Input Stuff --------------

#------------- [Command] stuff --------------------
print = (message) ->
  bottom = $('#tl20')
  current_text = bottom.text()
  message = message.split("\n")
  current_text += message.shift()
  bottom.html(substituteSpaces(current_text))
  for piece in message
    shiftOutput()
    bottom.html(substituteSpaces(piece))

printLine = (message = "") ->
  print("#{message}\n")

window.print = print
window.printL = printLine

runCommand = (command) ->
  args = command.split(" ")
  command = args.shift()
  command = COMMANDS[command]
  command(args) if(command != undefined)

window.runCommand = runCommand

runCommandLs = (args) ->
  dir = retrieveDir()
  result = ""
  for entry in dir['_entries']
    entry_text = if dir[entry]['_type'] == 'directory' then "<strong>#{entry}</strong>" else entry
    result += "#{entry_text}  "
  printLine(result)

runCommandCd = (args) ->
  dir = retrieveDir()
  if dir[args[0]] != undefined and dir[args[0]]['_type'] == 'directory'
    window.current_location = "#{window.current_location}/#{args[0]}"

runCommandMkdir = (args) ->
  dir = retrieveDir()
  for entry in args
    createDirectory(dir, entry) if dir[entry] == undefined

runCommandTouch = (args) ->
  dir = retrieveDir()
  for entry in args
    createFile(dir, entry) if dir[entry] == undefined

retrieveDir = () ->
  accessDirectory(window.current_location)

createDirectory = (dir, entry) ->
  dir[entry] =
    '..':     dir
    _type:    'directory'
    _entries: ['.', '..']
  dir[entry]['.'] = dir
  dir['_entries'].push(entry)
  dir[entry]

createFile = (dir, entry) ->
  dir[entry] =
    _type: 'file'
    text:  ""
  dir['_entries'].push(entry)
  dir[entry]

COMMANDS =
  ls:    runCommandLs
  cd:    runCommandCd
  mkdir: runCommandMkdir
  touch: runCommandTouch

shiftOutput = () ->
  for i in [1..19]
    do (i) ->
      previous = $("#tl#{i + 1}").html()
      $("#tl#{i}").html(previous)


# -------------- [Misc] -----------
retrieve_input_line = () ->
  ps1 = window.current_location
  "#{ps1}$ #{window.current_input}"

extract_input_line = () ->
  result = retrieve_input_line()
  $('#tl20').text("")
  result

extract_current_input = () ->
  command = window.current_input
  window.current_input = ""
  command

window.retrieve_input_line = retrieve_input_line

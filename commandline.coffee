# Skip to sections of this document by searching
# [File] for the handling of the pseudo file system
# [Input] for the handling of user keyboard input
# [Command] for operations involving commands that a user runs

$(document).ready(() ->
  prepareFileSystem()
  prepareKeyListener()
  prepareVisualConsole()
)

# --------------- [File] System Stuff -------------
#
# An entry is just text

# A file system object is a directory or a file
# Meta deta of an item is lead by _
# _type => 'directory' | 'file'
# a directory has _entries and links to other items
# a file has text
prepareFileSystem = () ->
  window.file_system =
    '':
      _type:    'directory'
      _entries: ['.', '..', 'home']
      home:
        _type:    'directory'
        _entries: ['.', '..', 'bob']
        bob:
          _type:    'directory'
          _entries: ['.', '..', 'example_file_1', 'example_file_2', 'example_directory_1']
          example_file_1:
            _type: 'file'
            text:  ""
          example_file_2:
            _type: 'file'
            text:  ""
          example_directory_1:
            _type:    'directory'
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
  input_text = substituteSpaces(retrieveInputLine())
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
  printLine(extractInputLine())
  command = extractCurrentInput()
  runCommand(command)
  updateCurrentInput()

RESERVED_KEYS =
  8:  inputBackspace
  13: inputEnter
window.reserved = RESERVED_KEYS

## -------- End of User Input Stuff --------------


TERMINAL_WIDTH = 80

# --------- [Print] Stuff ----------------------
print = (message) ->
  message = message.split("\n")
  bottom  = $('#tl20')
  current_text  = bottom.text()
  current_text += message.shift()
  injectToOutput(current_text)
  for piece in message
    shiftOutput()
    injectToOutput(piece)

printLine = (message = "") ->
  print("#{message}\n")

injectToOutput = (message) ->
  bottom  = $('#tl20')
  bottom.html(substituteSpaces(message)) if breakForLineBreaks(message)

# Either the message checks out(length is short enough) and it returns true
# Or the message doesn't check out. Split that message and send it through print
breakForLineBreaks = (message) ->
  bottom  = $('#tl20')
  current_bottom_text = bottom.text()
  return true if stripTags(message).length < TERMINAL_WIDTH

  words_and_tags = pairWordsAndTags(message)
  words = words_and_tags[0]
  tags  = words_and_tags[1]

  s_words = words.join(" ")
  front   = s_words.substring(0, 80)
  back    = s_words.substring(80)

  split_index = front.lastIndexOf(" ")

  back  = front.substring(split_index + 1) + back
  front = front.substring(0, split_index)

  back  = back.split(" ")
  front = front.split(" ")

  front_tags = []
  back_tags  = tags
  while front.length > front_tags.length
    front_tags.push(back_tags.shift())

  front = zipWordsAndTags(front, front_tags)
  back  = zipWordsAndTags(back, back_tags)

  console.log(front)
  console.log(back)

  printLine(front)
  print(back)
  false


window.print  = print
window.printL = printLine

#------------- [Command] stuff --------------------

runCommand = (command) ->
  args    = command.split(/\ +/)
  command_name = args.shift()
  command = COMMANDS[command_name]
  if(command != undefined) then command(args) else unrecognizedCommand(command_name, args)

window.runCommand = runCommand

unrecognizedCommand = (comm, args) ->
  printLine("#{comm}: command not found")

runCommandLs = (args) ->
  dir    = retrieveDir()
  result = ""
  for entry in dir['_entries']
    entry_text = if dir[entry]['_type'] == 'directory' then "<strong>#{entry}</strong>" else entry
    result += "#{entry_text} "
  printLine(result.trim())

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
retrieveInputLine = () ->
  ps1 = window.current_location
  "#{ps1}$ #{window.current_input}"

extractInputLine = () ->
  result = retrieveInputLine()
  $('#tl20').text("")
  result

extractCurrentInput = () ->
  command = window.current_input
  window.current_input = ""
  command

stripTags = (message) ->
  message.replace(/(<([^>]+)>)/ig,"")

jQuery.fn.outerHTML = () ->
  $('<div>').append( this.eq(0).clone() ).html()

# Assume there are no space in the tags
# Kinda meant for inline elements, so this is reasonable
pairWordsAndTags = (message) ->
  items = message.split(" ")
  tags  = items.map((t) -> extractTagName(t))
  items = items.map((t) -> stripTags(t))
  [items, tags]

# words_and_tags is a parallel list of words to tags
# Applies tags to the words and joins them into one string
# Assumes that parallel lists are of the same length
zipWordsAndTags = (words, tags) ->
  result = []
  for i in [0...words.length]
    item = $(document.createElement(tags[i])).text(words[i])
    result.push(item.outerHTML())
  result.join(" ")

extractTagName = (text) ->
  tag = $(text)
  if tag[0] != undefined then tag[0].tagName else "span"

# This is in misc because it's really just for debugging
# Makes json.. without the . or .. links
stringifyFileSystem = () ->
  hashify = (root = window.file_system['']) ->
    result = $.extend({}, root)
    if root['_type'] == 'directory'
      root['.'] = {}
      root['..'] = {}
      for entry in root['_entries']
        continue if entry == '.' or entry == '..'
        result[entry] = hashify(root[entry])
    result
  JSON.stringify(hashify())

window.retrieve_input_line = retrieveInputLine
window.pair = pairWordsAndTags
window.zip = zipWordsAndTags
window.fsStringify = stringifyFileSystem

# Skip to sections of this document by searching
# <File> for the handling of the pseudo file system
# <Input> for the handling of user keyboard input
# <Output> standard or file output
# <Command> for operations involving commands that a user runs
# <Misc> contains helper functions that are pretty low level/tinkery

$(document).ready(() ->
  prepareFileSystem()
  prepareKeyListener()
  prepareReadline()
)

# --------------- <File> System Stuff -------------
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


# --------------- User <Input> Stuff -------------

prepareReadline = () ->
  window.readline = 
    input: ""
    index: 0
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
  text  = window.readline['input']
  index = window.readline['index']
  window.readline['input'] = "#{text.slice(0, index)}#{character}#{text.slice(index)}"
  window.readline['index'] += 1
  updateCurrentInput()

updateCurrentInput = () ->
  input_text = substituteSpaces(retrieveInputLine(true))
  $('#tl20').html(input_text)

substituteSpaces = (input) ->
  input.replace(/\\{0} /g, "&nbsp;").replace(/\\{1}&nbsp;/g, " ")

handleReservedKey = (keyCode) ->
  RESERVED_KEYS[keyCode]()

# Individual functions for each reserved key

# Delete character at cursor
inputBackspace = () ->
  text  = window.readline['input']
  index = window.readline['index']
  return if index == 0
  window.readline['input']   = "#{text.slice(0, index - 1)}#{text.slice(index)}"
  window.readline['index'] -= 1
  updateCurrentInput()

# Submit command to be run
inputEnter = () ->
  printLine(extractInputLine())
  command = extractCurrentInput()
  runCommand(command)
  window.readline['index'] = 0
  updateCurrentInput()

# Tab autocomplete
inputTab = () ->
  text = window.readline['input']
  last_arg = text.substring(text.lastIndexOf(" ") + 1)
  possibility = null
  for entry in accessDirectory(window.current_location)['_entries']
    if entry.indexOf(last_arg) == 0
      if possibility != null
        possibility = false
      else
        possibility = entry
  if possibility != null and possibility != false
    window.readline['input'] = "#{text.substring(0, text.lastIndexOf(" ") + 1)}#{possibility}"
    window.readline['index'] = window.readline['input'].length
  updateCurrentInput()

# Move cursor left
inputLeft = () ->
  window.readline['index'] -= 1
  window.readline['index']  = 0 if window.readline['index'] < 0
  updateCurrentInput()

# Move cursor right
inputRight = () ->
  input_length = window.readline['input'].length
  window.readline['index'] += 1
  window.readline['index']  = input_length if window.readline['index'] > input_length
  updateCurrentInput()

RESERVED_KEYS =
  8:  inputBackspace
  13: inputEnter
  37: inputLeft
  39: inputRight
  9:  inputTab
window.reserved = RESERVED_KEYS

# ------------- Misc input stuff ---------------

retrieveInputLine = (use_index = false) ->
  index      = window.readline['index']
  input_text = "#{window.readline['input']} "
  if use_index
    input_text = "#{input_text.slice(0, index)}<span\\ id=\"readline_cursor\">#{input_text[index]}</span>#{input_text.slice(index + 1)}"
  ps1 = window.current_location
  "#{ps1}$ #{input_text}"

extractInputLine = () ->
  result = retrieveInputLine()
  $('#tl20').text("")
  result

extractCurrentInput = () ->
  command = window.readline['input']
  window.readline['input'] = ""
  command

## -------- End of User Input Stuff --------------
# --------- <Output> Stuff ----------------------

TERMINAL_WIDTH = 80

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

  printLine(front)
  print(back)
  false


window.print  = print
window.printL = printLine

#------------- <Command> stuff --------------------

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
  original_location = window.current_location
  targets = args[0].split("/")
  dir = if targets[0] != ""
    retrieveDir()
  else
    targets.shift()
    window.current_location = ""
    window.file_system[""]
  failure = false
  for target in targets
    if dir[target] != undefined
      if dir[target]['_type'] == 'directory'
        window.current_location = "#{window.current_location}/#{target}"
        dir = dir[target]
      else
        printL("cd: #{args[0]}: Not a directory")
        failure = true
        break
    else
      printL("cd: #{args[0]}: No such file or directory")
      failure = true
      break
  if failure
    window.current_location = original_location
  window.current_location

runCommandMkdir = (args) ->
  dir = retrieveDir()
  for entry in args
    createDirectory(dir, entry) if dir[entry] == undefined

runCommandTouch = (args) ->
  dir = retrieveDir()
  for entry in args
    createFile(dir, entry) if dir[entry] == undefined

runCommandEcho = (args) ->
  result = ""
  for item in args
    result += "#{item} "
  printLine(result.trim())

runCommandPwd = (args) ->
  printLine(window.current_location)

runCommandMv = (args) ->
  if args.length < 2
    printLine "mv: missing destination file operand after `#{args[0]}'"
    return

  target = args.pop()
  entry = args[0]

  old_dir = retrieveDir()

  if old_dir[target] != undefined
    if old_dir[target]['_type'] == 'directory'
      new_dir = old_dir[target]
      target_name = entry
    else
      printL("mv: target `#{target}' is not a directory")
      return
  else
    target_name = target
    new_dir = old_dir

  # Rewrite state given entry, target_name, new_dir, old_dir
  new_dir[target_name] = old_dir[entry]
  delete old_dir[entry]

  entries = old_dir['_entries']
  old_loc = entries.indexOf(entry)
  old_dir['_entries'] = entries.slice(0, old_loc).concat entries.slice(old_loc + 1, entries.length)

  new_dir['_entries'].push(target_name)

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
  echo:  runCommandEcho
  pwd:   runCommandPwd
  mv:    runCommandMv

shiftOutput = () ->
  for i in [1..19]
    do (i) ->
      previous = $("#tl#{i + 1}").html()
      $("#tl#{i}").html(previous)


# -------------- <Misc> -----------

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
      root['.'] = {} if root['.'] != undefined
      root['..'] = {} if root['..'] != undefined
      for entry in root['_entries']
        continue if entry == '.' or entry == '..'
        result[entry] = hashify(root[entry])
    result
  JSON.stringify(hashify())

window.retrieve_input_line = retrieveInputLine
window.pair = pairWordsAndTags
window.zip = zipWordsAndTags
window.fsStringify = stringifyFileSystem

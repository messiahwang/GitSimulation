$(document).ready(() ->
  prepareVisualConsole()
  prepareFileSystem()
  prepareKeyListener()
  setCommands()
)

prepareVisualConsole = () ->
  window.current_input = ""

prepareFileSystem = () ->
  window.file_system =
    home:
       bob: {}

# --------------- User Input Stuff -------------

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
  console.log(character)
  updateCurrentInput()

updateCurrentInput = () ->
  $('#tl20').text(window.current_input)

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
runCommand = (command) ->
  shiftOutput()
  $('#tl19').text(command)

shiftOutput = () ->
  for i in [1..18]
    do (i) ->
      previous = $("#tl#{i + 1}").text()
      console.log(previous)
      $("#tl#{i}").text(previous)

setCommands = () ->



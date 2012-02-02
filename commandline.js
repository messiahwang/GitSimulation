(function() {
  var RESERVED_KEYS, handleKeyPress, handleReservedKey, injectToInput, inputBackspace, inputEnter, prepareFileSystem, prepareKeyListener, prepareVisualConsole, runCommand, setCommands, shiftOutput, updateCurrentInput;
  $(document).ready(function() {
    prepareVisualConsole();
    prepareFileSystem();
    prepareKeyListener();
    return setCommands();
  });
  prepareVisualConsole = function() {
    return window.current_input = "";
  };
  prepareFileSystem = function() {
    return window.file_system = {
      home: {
        bob: {}
      }
    };
  };
  prepareKeyListener = function() {
    $(document).keypress(function(e) {
      return handleKeyPress(e);
    });
    return $(document).keydown(function(e) {
      if (RESERVED_KEYS[e.keyCode]) {
        handleKeyPress(e);
        return false;
      }
    });
  };
  handleKeyPress = function(e) {
    var keyCode, reserved;
    reserved = false;
    keyCode = e.keyCode;
    if (RESERVED_KEYS[keyCode]) {
      return handleReservedKey(keyCode);
    } else {
      return injectToInput(String.fromCharCode(keyCode));
    }
  };
  injectToInput = function(character) {
    window.current_input += character;
    console.log(character);
    return updateCurrentInput();
  };
  updateCurrentInput = function() {
    return $('#tl20').text(window.current_input);
  };
  handleReservedKey = function(keyCode) {
    return RESERVED_KEYS[keyCode]();
  };
  inputBackspace = function() {
    var current;
    current = window.current_input;
    window.current_input = current.substring(0, current.length - 1);
    return updateCurrentInput();
  };
  inputEnter = function() {
    var command;
    command = window.current_input;
    window.current_input = "";
    runCommand(command);
    return updateCurrentInput();
  };
  RESERVED_KEYS = {
    8: inputBackspace,
    13: inputEnter
  };
  window.reserved = RESERVED_KEYS;
  runCommand = function(command) {
    shiftOutput();
    return $('#tl19').text(command);
  };
  shiftOutput = function() {
    var i, _results;
    _results = [];
    for (i = 1; i <= 18; i++) {
      _results.push((function(i) {
        var previous;
        previous = $("#tl" + (i + 1)).text();
        console.log(previous);
        return $("#tl" + i).text(previous);
      })(i));
    }
    return _results;
  };
  setCommands = function() {};
}).call(this);

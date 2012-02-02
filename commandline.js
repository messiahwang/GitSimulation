(function() {
  var COMMANDS, RESERVED_KEYS, accessDirectory, crawl, createDirectory, handleKeyPress, handleReservedKey, injectToInput, inputBackspace, inputEnter, prepareFileSystem, prepareKeyListener, prepareVisualConsole, print, retrieveDir, runCommand, runCommandcd, runCommandls, runCommandmkdir, shiftOutput, updateCurrentInput;
  $(document).ready(function() {
    prepareFileSystem();
    prepareKeyListener();
    return prepareVisualConsole();
  });
  prepareFileSystem = function() {
    window.file_system = {
      '/': {
        _type: 'directory',
        _entries: ['.', '..', 'home'],
        home: {
          _type: 'directory',
          _entries: ['.', '..', 'bob'],
          bob: {
            _type: 'directory',
            _entries: ['.', '..', 'a', 'b', 'c'],
            a: {
              _type: 'file'
            },
            b: {
              _type: 'file'
            },
            c: {
              _type: 'file'
            }
          }
        }
      }
    };
    window.current_location = "/home/bob";
    return crawl(window.file_system['/'], '/', function(dir, dirname, entry) {
      if (entry === '.') {
        dir[entry] = dir;
      }
      if (dir[entry]['_type'] === 'directory') {
        false;
        console.log("==> " + dirname + ", " + entry);
        if (dir[entry]['..'] === void 0) {
          return dir[entry]['..'] = dir;
        }
      }
    });
  };
  crawl = function(current_dir, current_name, action) {
    var continue_crawl, entries, entry, _i, _len, _results;
    if (current_dir == null) {
      current_dir = window.file_system['/'];
    }
    if (action == null) {
      action = null;
    }
    entries = current_dir['_entries'];
    _results = [];
    for (_i = 0, _len = entries.length; _i < _len; _i++) {
      entry = entries[_i];
      console.log(entry);
      if (action !== null) {
        action(current_dir, current_name, entry);
      }
      continue_crawl = current_dir[entry] !== void 0 && current_dir[entry]['_type'] === 'directory';
      continue_crawl = continue_crawl && current_dir[entry] !== current_dir;
      continue_crawl = continue_crawl && current_dir[entry][current_name] !== current_dir;
      _results.push(continue_crawl ? crawl(current_dir[entry], entry, action) : void 0);
    }
    return _results;
  };
  window.crawl = crawl;
  accessDirectory = function(pathname) {
    var current_spot, path, paths, _i, _len;
    paths = pathname.split("/");
    paths.shift();
    current_spot = window.file_system['/'];
    for (_i = 0, _len = paths.length; _i < _len; _i++) {
      path = paths[_i];
      current_spot = current_spot[path];
    }
    return current_spot;
  };
  window.accessDirectory = accessDirectory;
  prepareVisualConsole = function() {
    window.current_input = "";
    return updateCurrentInput();
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
    return updateCurrentInput();
  };
  updateCurrentInput = function() {
    var ps1;
    ps1 = window.current_location;
    return $('#tl20').text("" + ps1 + "$ " + window.current_input);
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
  print = function(message) {
    var bottom;
    bottom = $('#tl19');
    return bottom.text(bottom.text() + message);
  };
  runCommand = function(command) {
    var args;
    shiftOutput();
    args = command.split(" ");
    console.log(args);
    command = args.shift();
    console.log(command);
    command = COMMANDS[command];
    if (command !== void 0) {
      return command(args);
    }
  };
  runCommandls = function(args) {
    var dir, entry, _i, _len, _ref, _results;
    dir = retrieveDir();
    _ref = dir['_entries'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      entry = _ref[_i];
      _results.push(print("" + entry + " "));
    }
    return _results;
  };
  runCommandcd = function(args) {
    var dir;
    dir = retrieveDir();
    if (dir[args[0]] !== void 0 && dir[args[0]]['_type'] === 'directory') {
      return window.current_location = "" + window.current_location + "/" + args[0];
    }
  };
  runCommandmkdir = function(args) {
    var dir, entry, _i, _len, _results;
    dir = retrieveDir();
    _results = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      entry = args[_i];
      _results.push(dir[entry] === void 0 ? createDirectory(dir, entry) : void 0);
    }
    return _results;
  };
  retrieveDir = function() {
    return accessDirectory(window.current_location);
  };
  createDirectory = function(dir, entry) {
    dir[entry] = {
      '..': dir,
      _type: 'directory',
      _entries: ['.', '..']
    };
    dir[entry]['.'] = dir;
    dir['_entries'].push(entry);
    return dir;
  };
  COMMANDS = {
    ls: runCommandls,
    cd: runCommandcd,
    mkdir: runCommandmkdir
  };
  shiftOutput = function() {
    var i, _fn;
    _fn = function(i) {
      var previous;
      previous = $("#tl" + (i + 1)).text();
      return $("#tl" + i).text(previous);
    };
    for (i = 1; i <= 18; i++) {
      _fn(i);
    }
    return $('#tl19').text("");
  };
}).call(this);

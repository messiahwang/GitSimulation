(function() {
  var COMMANDS, RESERVED_KEYS, TERMINAL_WIDTH, accessDirectory, breakForLineBreaks, crawl, createDirectory, createFile, extractCurrentInput, extractInputLine, extractTagName, handleKeyPress, handleReservedKey, injectToInput, injectToOutput, inputBackspace, inputEnter, pairWordsAndTags, prepareFileSystem, prepareKeyListener, prepareVisualConsole, print, printLine, retrieveDir, retrieveInputLine, runCommand, runCommandCd, runCommandLs, runCommandMkdir, runCommandTouch, setCurrentAndParentReferences, shiftOutput, stringifyFileSystem, stripTags, substituteSpaces, unrecognizedCommand, updateCurrentInput, zipWordsAndTags;
  $(document).ready(function() {
    prepareFileSystem();
    prepareKeyListener();
    return prepareVisualConsole();
  });
  prepareFileSystem = function() {
    window.file_system = {
      '': {
        _type: 'directory',
        _entries: ['.', '..', 'home'],
        home: {
          _type: 'directory',
          _entries: ['.', '..', 'bob'],
          bob: {
            _type: 'directory',
            _entries: ['.', '..', 'example_file_1', 'example_file_2', 'example_directory_1'],
            example_file_1: {
              _type: 'file',
              text: ""
            },
            example_file_2: {
              _type: 'file',
              text: ""
            },
            example_directory_1: {
              _type: 'directory',
              _entries: ['.', '..']
            }
          }
        }
      }
    };
    window.current_location = "/home/bob";
    return setCurrentAndParentReferences();
  };
  setCurrentAndParentReferences = function() {
    window.file_system['']['home']['..'] = window.file_system['/'];
    return crawl(window.file_system[''], '', function(dir, dirname, entry) {
      if (entry === '.') {
        dir[entry] = dir;
      }
      if (dir[entry]['_type'] === 'directory') {
        false;
        if (dir[entry]['..'] === void 0) {
          return dir[entry]['..'] = dir;
        }
      }
    });
  };
  crawl = function(current_dir, current_name, action) {
    var continue_crawl, entries, entry, _i, _len, _results;
    if (current_dir == null) {
      current_dir = window.file_system[''];
    }
    if (action == null) {
      action = null;
    }
    entries = current_dir['_entries'];
    _results = [];
    for (_i = 0, _len = entries.length; _i < _len; _i++) {
      entry = entries[_i];
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
    current_spot = window.file_system[''];
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
    var input_text;
    input_text = substituteSpaces(retrieveInputLine());
    return $('#tl20').html(input_text);
  };
  substituteSpaces = function(input) {
    return input.replace(/\ /g, "&nbsp;");
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
    printLine(extractInputLine());
    command = extractCurrentInput();
    runCommand(command);
    return updateCurrentInput();
  };
  RESERVED_KEYS = {
    8: inputBackspace,
    13: inputEnter
  };
  window.reserved = RESERVED_KEYS;
  TERMINAL_WIDTH = 80;
  print = function(message) {
    var bottom, current_text, piece, _i, _len, _results;
    message = message.split("\n");
    bottom = $('#tl20');
    current_text = bottom.text();
    current_text += message.shift();
    injectToOutput(current_text);
    _results = [];
    for (_i = 0, _len = message.length; _i < _len; _i++) {
      piece = message[_i];
      shiftOutput();
      _results.push(injectToOutput(piece));
    }
    return _results;
  };
  printLine = function(message) {
    if (message == null) {
      message = "";
    }
    return print("" + message + "\n");
  };
  injectToOutput = function(message) {
    var bottom;
    bottom = $('#tl20');
    if (breakForLineBreaks(message)) {
      return bottom.html(substituteSpaces(message));
    }
  };
  breakForLineBreaks = function(message) {
    var back, back_tags, bottom, current_bottom_text, front, front_tags, s_words, split_index, tags, words, words_and_tags;
    bottom = $('#tl20');
    current_bottom_text = bottom.text();
    if (stripTags(message).length < TERMINAL_WIDTH) {
      return true;
    }
    words_and_tags = pairWordsAndTags(message);
    words = words_and_tags[0];
    tags = words_and_tags[1];
    s_words = words.join(" ");
    front = s_words.substring(0, 80);
    back = s_words.substring(80);
    split_index = front.lastIndexOf(" ");
    back = front.substring(split_index + 1) + back;
    front = front.substring(0, split_index);
    back = back.split(" ");
    front = front.split(" ");
    front_tags = [];
    back_tags = tags;
    while (front.length > front_tags.length) {
      front_tags.push(back_tags.shift());
    }
    front = zipWordsAndTags(front, front_tags);
    back = zipWordsAndTags(back, back_tags);
    console.log(front);
    console.log(back);
    printLine(front);
    print(back);
    return false;
  };
  window.print = print;
  window.printL = printLine;
  runCommand = function(command) {
    var args, command_name;
    args = command.split(/\ +/);
    command_name = args.shift();
    command = COMMANDS[command_name];
    if (command !== void 0) {
      return command(args);
    } else {
      return unrecognizedCommand(command_name, args);
    }
  };
  window.runCommand = runCommand;
  unrecognizedCommand = function(comm, args) {
    return printLine("" + comm + ": command not found");
  };
  runCommandLs = function(args) {
    var dir, entry, entry_text, result, _i, _len, _ref;
    dir = retrieveDir();
    result = "";
    _ref = dir['_entries'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      entry = _ref[_i];
      entry_text = dir[entry]['_type'] === 'directory' ? "<strong>" + entry + "</strong>" : entry;
      result += "" + entry_text + " ";
    }
    return printLine(result.trim());
  };
  runCommandCd = function(args) {
    var dir;
    dir = retrieveDir();
    if (dir[args[0]] !== void 0 && dir[args[0]]['_type'] === 'directory') {
      return window.current_location = "" + window.current_location + "/" + args[0];
    }
  };
  runCommandMkdir = function(args) {
    var dir, entry, _i, _len, _results;
    dir = retrieveDir();
    _results = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      entry = args[_i];
      _results.push(dir[entry] === void 0 ? createDirectory(dir, entry) : void 0);
    }
    return _results;
  };
  runCommandTouch = function(args) {
    var dir, entry, _i, _len, _results;
    dir = retrieveDir();
    _results = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      entry = args[_i];
      _results.push(dir[entry] === void 0 ? createFile(dir, entry) : void 0);
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
    return dir[entry];
  };
  createFile = function(dir, entry) {
    dir[entry] = {
      _type: 'file',
      text: ""
    };
    dir['_entries'].push(entry);
    return dir[entry];
  };
  COMMANDS = {
    ls: runCommandLs,
    cd: runCommandCd,
    mkdir: runCommandMkdir,
    touch: runCommandTouch
  };
  shiftOutput = function() {
    var i, _results;
    _results = [];
    for (i = 1; i <= 19; i++) {
      _results.push((function(i) {
        var previous;
        previous = $("#tl" + (i + 1)).html();
        return $("#tl" + i).html(previous);
      })(i));
    }
    return _results;
  };
  retrieveInputLine = function() {
    var ps1;
    ps1 = window.current_location;
    return "" + ps1 + "$ " + window.current_input;
  };
  extractInputLine = function() {
    var result;
    result = retrieveInputLine();
    $('#tl20').text("");
    return result;
  };
  extractCurrentInput = function() {
    var command;
    command = window.current_input;
    window.current_input = "";
    return command;
  };
  stripTags = function(message) {
    return message.replace(/(<([^>]+)>)/ig, "");
  };
  jQuery.fn.outerHTML = function() {
    return $('<div>').append(this.eq(0).clone()).html();
  };
  pairWordsAndTags = function(message) {
    var items, tags;
    items = message.split(" ");
    tags = items.map(function(t) {
      return extractTagName(t);
    });
    items = items.map(function(t) {
      return stripTags(t);
    });
    return [items, tags];
  };
  zipWordsAndTags = function(words, tags) {
    var i, item, result, _ref;
    result = [];
    for (i = 0, _ref = words.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      item = $(document.createElement(tags[i])).text(words[i]);
      result.push(item.outerHTML());
    }
    return result.join(" ");
  };
  extractTagName = function(text) {
    var tag;
    tag = $(text);
    if (tag[0] !== void 0) {
      return tag[0].tagName;
    } else {
      return "span";
    }
  };
  stringifyFileSystem = function() {
    var hashify;
    hashify = function(root) {
      var entry, result, _i, _len, _ref;
      if (root == null) {
        root = window.file_system[''];
      }
      result = $.extend({}, root);
      if (root['_type'] === 'directory') {
        root['.'] = {};
        root['..'] = {};
        _ref = root['_entries'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          if (entry === '.' || entry === '..') {
            continue;
          }
          result[entry] = hashify(root[entry]);
        }
      }
      return result;
    };
    return JSON.stringify(hashify());
  };
  window.retrieve_input_line = retrieveInputLine;
  window.pair = pairWordsAndTags;
  window.zip = zipWordsAndTags;
  window.fsStringify = stringifyFileSystem;
}).call(this);

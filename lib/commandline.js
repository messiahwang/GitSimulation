(function() {
  var COMMANDS, GITCOMMANDS, RESERVED_KEYS, TERMINAL_WIDTH, accessDirectory, addToDirectoryIndex, assignId, assignUniqueIds, breakForLineBreaks, cleanLinks, cloneFileSystem, crawl, createBranch, createDirectory, createFile, extractCurrentInput, extractInputLine, extractTagName, getGitDir, getIntersection, getLinkName, handleKeyPress, handleReservedKey, hashFileSystem, hashNonLinkData, injectToInput, injectToOutput, inputBackspace, inputEnter, inputLeft, inputRight, inputTab, listBranches, makeDirectories, pairWordsAndTags, prepareFileSystem, prepareKeyListener, prepareReadline, print, printLine, replaceDummyNodes, retrieveDir, retrieveInputLine, runCommand, runCommandCd, runCommandEcho, runCommandGit, runCommandLs, runCommandMkdir, runCommandMv, runCommandPwd, runCommandTouch, runFromList, runGitBranch, runGitCheckout, runGitInit, setCurrentAndParentReferences, shiftOutput, stringifyFileSystem, stripTags, substituteSpaces, unrecognizedCommand, updateCurrentInput, zipWordsAndTags;
  $(document).ready(function() {
    prepareFileSystem();
    prepareKeyListener();
    prepareReadline();
    return window.initializeObserver();
  });
  prepareFileSystem = function() {
    window.file_system = {
      top_id: 2,
      '': {
        _id: 1,
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
    assignUniqueIds();
    return setCurrentAndParentReferences();
  };
  setCurrentAndParentReferences = function() {
    window.file_system['']['home']['..'] = window.file_system['/'];
    return crawl(window.file_system[''], '', function(dir, dirname, entry) {
      if (entry === '.') {
        dir[entry] = dir;
      }
      if (dir[entry]['_type'] === 'directory') {
        if (dir[entry]['..'] === void 0) {
          return dir[entry]['..'] = dir;
        }
      }
    });
  };
  assignUniqueIds = function() {
    return crawl(window.file_system[''], '', function(dir, dirname, entry) {
      if (entry !== '.' && entry !== '..') {
        assignId(dir[entry]);
      }
      return window.file_system.top_id += 1;
    });
  };
  assignId = function(dir) {
    dir['_id'] = window.file_system.top_id;
    window.file_system.top_id += 1;
    return dir;
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
  prepareReadline = function() {
    window.readline = {
      input: "",
      index: 0
    };
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
    var index, text;
    text = window.readline['input'];
    index = window.readline['index'];
    window.readline['input'] = "" + (text.slice(0, index)) + character + (text.slice(index));
    window.readline['index'] += 1;
    return updateCurrentInput();
  };
  updateCurrentInput = function() {
    var input_text;
    input_text = substituteSpaces(retrieveInputLine(true));
    return $('#tl20').html(input_text);
  };
  substituteSpaces = function(input) {
    return input.replace(/\\{0} /g, "&nbsp;").replace(/\\{1}&nbsp;/g, " ");
  };
  handleReservedKey = function(keyCode) {
    return RESERVED_KEYS[keyCode]();
  };
  inputBackspace = function() {
    var index, text;
    text = window.readline['input'];
    index = window.readline['index'];
    if (index === 0) {
      return;
    }
    window.readline['input'] = "" + (text.slice(0, index - 1)) + (text.slice(index));
    window.readline['index'] -= 1;
    return updateCurrentInput();
  };
  inputEnter = function() {
    var command;
    printLine(extractInputLine());
    command = extractCurrentInput();
    runCommand(command);
    window.readline['index'] = 0;
    return updateCurrentInput();
  };
  inputTab = function() {
    var entry, intersect, last_arg, possibilities, text, _i, _len, _ref;
    text = window.readline['input'];
    last_arg = text.substring(text.lastIndexOf(" ") + 1);
    possibilities = [];
    _ref = accessDirectory(window.current_location)['_entries'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      entry = _ref[_i];
      if (entry.indexOf(last_arg) === 0) {
        possibilities.push(entry);
      }
    }
    intersect = getIntersection(possibilities);
    if (intersect) {
      window.readline['input'] = "" + (text.substring(0, text.lastIndexOf(" ") + 1)) + intersect;
      window.readline['index'] = window.readline['input'].length;
    }
    return updateCurrentInput();
  };
  inputLeft = function() {
    window.readline['index'] -= 1;
    if (window.readline['index'] < 0) {
      window.readline['index'] = 0;
    }
    return updateCurrentInput();
  };
  inputRight = function() {
    var input_length;
    input_length = window.readline['input'].length;
    window.readline['index'] += 1;
    if (window.readline['index'] > input_length) {
      window.readline['index'] = input_length;
    }
    return updateCurrentInput();
  };
  RESERVED_KEYS = {
    8: inputBackspace,
    13: inputEnter,
    37: inputLeft,
    39: inputRight,
    9: inputTab
  };
  retrieveInputLine = function(use_index) {
    var index, input_text, ps1;
    if (use_index == null) {
      use_index = false;
    }
    index = window.readline['index'];
    input_text = "" + window.readline['input'] + " ";
    if (use_index) {
      input_text = "" + (input_text.slice(0, index)) + "<span\\ id=\"readline_cursor\">" + input_text[index] + "</span>" + (input_text.slice(index + 1));
    }
    ps1 = window.current_location;
    return "" + ps1 + "$ " + input_text;
  };
  extractInputLine = function() {
    var result;
    result = retrieveInputLine();
    $('#tl20').text("");
    return result;
  };
  extractCurrentInput = function() {
    var command;
    command = window.readline['input'];
    window.readline['input'] = "";
    return command;
  };
  getIntersection = function(inputs) {
    var i, j, letters, maxlength, result, _ref;
    if (inputs.length === 0) {
      return inputs[0];
    }
    maxlength = Math.min.apply(Math, inputs.map(function(inp) {
      return inp.length;
    }));
    result = "";
    for (i = 0; 0 <= maxlength ? i < maxlength : i > maxlength; 0 <= maxlength ? i++ : i--) {
      letters = inputs.map(function(inp) {
        return inp[i];
      });
      for (j = 1, _ref = letters.length; 1 <= _ref ? j < _ref : j > _ref; 1 <= _ref ? j++ : j--) {
        if (letters[0] === letters[j]) {} else {
          return result;
        }
      }
      result += letters[0];
    }
    return result;
  };
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
    printLine(front);
    print(back);
    return false;
  };
  runCommand = function(command) {
    var args;
    args = command.split(/\ +/);
    return runFromList(args, COMMANDS);
  };
  runFromList = function(args, list) {
    var command, command_name;
    command_name = args.shift();
    command = list[command_name];
    if (command !== void 0) {
      return command(args);
    } else {
      return unrecognizedCommand(command_name, args);
    }
  };
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
    var dir, failure, original_location, target, targets, _i, _len;
    original_location = window.current_location;
    targets = args[0].split("/");
    dir = targets[0] !== "" ? retrieveDir() : (targets.shift(), window.current_location = "", window.file_system[""]);
    failure = false;
    for (_i = 0, _len = targets.length; _i < _len; _i++) {
      target = targets[_i];
      if (dir[target] !== void 0) {
        if (dir[target]['_type'] === 'directory') {
          window.current_location = "" + window.current_location + "/" + target;
          dir = dir[target];
        } else {
          printLine("cd: " + args[0] + ": Not a directory");
          failure = true;
          break;
        }
      } else {
        printLine("cd: " + args[0] + ": No such file or directory");
        failure = true;
        break;
      }
    }
    if (failure) {
      window.current_location = original_location;
    }
    window.current_location = cleanLinks(window.current_location);
    return window.current_location;
  };
  runCommandMkdir = function(args) {
    var dir;
    dir = retrieveDir();
    return makeDirectories(dir, args);
  };
  makeDirectories = function(dir, entries) {
    var entry, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = entries.length; _i < _len; _i++) {
      entry = entries[_i];
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
  runCommandEcho = function(args) {
    var item, result, _i, _len;
    result = "";
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      item = args[_i];
      result += "" + item + " ";
    }
    return printLine(result.trim());
  };
  runCommandPwd = function(args) {
    return printLine(window.current_location);
  };
  runCommandMv = function(args) {
    var entries, entry, new_dir, old_dir, old_loc, target, target_name;
    if (args.length < 2) {
      printLine("mv: missing destination file operand after `" + args[0] + "'");
      return;
    }
    target = args.pop();
    entry = args[0];
    old_dir = retrieveDir();
    if (old_dir[target] !== void 0) {
      if (old_dir[target]['_type'] === 'directory') {
        new_dir = old_dir[target];
        target_name = entry;
      } else {
        printLine("mv: target `" + target + "' is not a directory");
        return;
      }
    } else {
      target_name = target;
      new_dir = old_dir;
    }
    new_dir[target_name] = old_dir[entry];
    delete old_dir[entry];
    entries = old_dir['_entries'];
    old_loc = entries.indexOf(entry);
    old_dir['_entries'] = entries.slice(0, old_loc).concat(entries.slice(old_loc + 1, entries.length));
    return new_dir['_entries'].push(target_name);
  };
  retrieveDir = function() {
    return accessDirectory(window.current_location);
  };
  createDirectory = function(dir, entry) {
    if (dir[entry] !== void 0) {
      return false;
    }
    dir[entry] = {
      '..': dir,
      _type: 'directory',
      _entries: ['.', '..']
    };
    dir[entry]['.'] = dir;
    return addToDirectoryIndex(dir, entry);
  };
  createFile = function(dir, entry) {
    dir[entry] = {
      _type: 'file',
      text: ""
    };
    return addToDirectoryIndex(dir, entry);
  };
  addToDirectoryIndex = function(dir, entry) {
    assignId(dir[entry]);
    dir['_entries'].push(entry);
    return dir[entry];
  };
  runCommandGit = function(args) {
    return runFromList(args, GITCOMMANDS);
  };
  COMMANDS = {
    ls: runCommandLs,
    cd: runCommandCd,
    mkdir: runCommandMkdir,
    touch: runCommandTouch,
    echo: runCommandEcho,
    pwd: runCommandPwd,
    mv: runCommandMv,
    git: runCommandGit
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
  runGitInit = function(args) {
    var branch_dir, dir;
    dir = retrieveDir();
    if (!createDirectory(dir, '.git')) {
      printLine("Reinitialized existing Git repository in " + window.current_location + "/.git/");
      return;
    }
    printLine("Initialized empty Git repository in " + window.current_location + "/.git/");
    createDirectory(dir['.git'], 'branches');
    branch_dir = dir['.git']['branches'];
    branch_dir['_branches'] = [];
    branch_dir['master'] = dir;
    branch_dir['_current'] = "master";
    branch_dir['_entries'].push('master');
    return branch_dir['_branches'].push('master');
  };
  runGitBranch = function(args) {
    var result;
    if (args.length === 0) {
      return listBranches();
    } else {
      result = createBranch(args[0]);
      if (result === false) {
        return printLine("fatal: A branch named '" + args[0] + "' already exists.");
      }
    }
  };
  runGitCheckout = function(args) {
    var branch_dir, git_dir, pre_root_dir, pre_root_name, target_branch, target_branch_name;
    git_dir = getGitDir();
    if (args.length === 0 || git_dir === null) {
      return;
    }
    target_branch_name = args[0];
    branch_dir = git_dir['branches'];
    if (branch_dir['_entries'].indexOf(target_branch_name) !== -1) {
      target_branch = branch_dir[target_branch_name];
      branch_dir['_current'] = target_branch_name;
      pre_root_dir = git_dir['..']['..'];
      pre_root_name = getLinkName(pre_root_dir, git_dir['..']);
      pre_root_dir[pre_root_name] = target_branch;
      target_branch['..'] = pre_root_dir;
      return git_dir['..'] = target_branch;
    }
  };
  GITCOMMANDS = {
    init: runGitInit,
    branch: runGitBranch,
    checkout: runGitCheckout
  };
  listBranches = function() {
    var current, entries, entry, git_dir, result, _i, _len;
    git_dir = getGitDir();
    if (git_dir === null) {
      return;
    }
    entries = git_dir['branches']['_branches'];
    current = git_dir['branches']['_current'];
    result = "";
    for (_i = 0, _len = entries.length; _i < _len; _i++) {
      entry = entries[_i];
      result += "" + (entry === current ? "* " : "  ") + entry + "\n";
    }
    print(result);
    return git_dir;
  };
  createBranch = function(branch_name) {
    var branch_dir, git_dir, new_branch;
    git_dir = getGitDir();
    if (git_dir === null) {
      return;
    }
    if (git_dir['branches']['_entries'].indexOf(branch_name) !== -1) {
      return false;
    }
    new_branch = cloneFileSystem(git_dir['..']);
    new_branch['.git'] = git_dir;
    branch_dir = git_dir['branches'];
    branch_dir['_entries'].push(branch_name);
    branch_dir['_branches'].push(branch_name);
    branch_dir[branch_name] = new_branch;
    return true;
  };
  getGitDir = function(curr) {
    if (curr == null) {
      curr = retrieveDir();
    }
    if (curr['.git'] !== void 0) {
      return curr['.git'];
    } else if (curr === window.file_system['']) {
      printLine("fatal: Not a git repository (or any of the parent directories): git");
      return null;
    } else {
      return getGitDir(curr['..']);
    }
  };
  getLinkName = function(parent, dir) {
    var entry, _i, _len, _ref;
    console.log(parent);
    console.log(dir);
    if (parent === window.file_system) {
      return '';
    }
    _ref = parent['_entries'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      entry = _ref[_i];
      if (parent[entry] === dir) {
        return entry;
      }
    }
    return null;
  };
  cleanLinks = function(link) {
    link = link.replace(/\/[\.a-zA-z0-9]*\/\.\./, "").replace(/^\.*/, "");
    return link.replace(/\/\.$/, "").replace(/\/\.\//, "/");
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
  stringifyFileSystem = function(root) {
    if (root == null) {
      root = window.file_system[''];
    }
    return JSON.stringify(hashFileSystem(root));
  };
  window.fsStringify = stringifyFileSystem;
  hashFileSystem = function(root, accessed_table) {
    var entry, result, _i, _len, _ref;
    if (root == null) {
      root = window.file_system[''];
    }
    if (accessed_table == null) {
      accessed_table = {};
    }
    result = $.extend({}, root);
    hashNonLinkData(result);
    accessed_table[root['_id']] = result;
    if (root['_type'] === 'directory') {
      _ref = root['_entries'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        entry = _ref[_i];
        result[entry] = accessed_table[result[entry]['_id']] ? {
          '_id': result[entry]['_id'],
          '_type': 'dummy'
        } : hashFileSystem(root[entry], accessed_table);
      }
    }
    return result;
  };
  hashNonLinkData = function(root) {
    if (root['_entries']) {
      return root['_entries'] = root['_entries'].slice(0);
    }
  };
  cloneFileSystem = function(root) {
    var clone, reference_table;
    if (root == null) {
      root = window.file_system[''];
    }
    reference_table = {};
    clone = hashFileSystem(root, reference_table);
    return replaceDummyNodes(clone, reference_table);
  };
  replaceDummyNodes = function(root, reference_table) {
    var entry, _i, _len, _ref;
    if (root['_type'] === 'directory') {
      _ref = root['_entries'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        entry = _ref[_i];
        if (root[entry]['_type'] === 'dummy') {
          root[entry] = reference_table[root[entry]['_id']];
        } else {
          replaceDummyNodes(root[entry], reference_table);
        }
      }
    }
    return root;
  };
  window.fsHash = hashFileSystem;
  window.fsClone = cloneFileSystem;
}).call(this);

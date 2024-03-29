(function() {
  var TUTORIAL, checkRule, generateExistTest, generateHasTextTest, generateRanCommandTest, generateTest, generateTests, initializeObserver, monitor, nextRule, observeLoop, prepareRule, reset, setInstructionText;
  TUTORIAL = [
    {
      text: ["Welcome to this interactive Git tutorial! The difficulty of this is meant for if you have sort of used the command line before but don't really understand anything.", "Let's start by making a new git project. Make a directory called <strong>project</strong> in bob's home directory.", "You can use the <strong>mkdir</strong> command to make this directory."],
      rules: ["exists /home/bob/project"]
    }, {
      text: ["Awesome. We want to initialize this as a git repository.", "Run <strong>git init</strong> within the project directory. You'll probably want to <strong>cd</strong> into it first."],
      rules: ["exists /home/bob/project/.git"]
    }
  ];
  initializeObserver = function() {
    window.observer = {
      tests: [
        function() {
          return false;
        }
      ],
      current_step: 0,
      tutorial: TUTORIAL
    };
    window.observer.nextRule = nextRule;
    return observeLoop();
  };
  observeLoop = function() {
    var item;
    window.observer.monitor_timer = setInterval(monitor, 500);
    item = window.observer.tutorial[window.observer.current_step];
    return prepareRule(item);
  };
  reset = function() {
    clearInterval(window.observer.monitor_timer);
    window.current_step = 0;
    return observeLoop();
  };
  monitor = function() {
    if (checkRule()) {
      return nextRule();
    }
  };
  nextRule = function() {
    var current_step, rule, tutorial;
    tutorial = window.observer.tutorial;
    window.observer.current_step += 1;
    current_step = window.observer.current_step;
    if (current_step < tutorial.length) {
      return rule = prepareRule(tutorial[current_step]);
    } else {
      setInstructionText("You've cleared this tutorial! It's unfortunate that there isn't more yet. Congrats.. you can move on with your life");
      return clearInterval(window.observer.monitor_timer);
    }
  };
  prepareRule = function(item) {
    var text;
    text = item['text'];
    setInstructionText(text);
    return window.observer['tests'] = generateTests(item['rules']);
  };
  checkRule = function() {
    var test, _i, _len, _ref;
    _ref = window.observer['tests'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      test = _ref[_i];
      if (!test()) {
        return false;
      }
    }
    return true;
  };
  generateTests = function(rules) {
    return rules.map(generateTest);
  };
  generateTest = function(rule) {
    var args, type;
    args = rule.split(/\ +/);
    type = args.shift();
    switch (type) {
      case "exists":
        return generateExistTest(args);
      case "has_text":
        return generateHasTextTest(args);
      case "ran_command":
        return generateRanCommandTest(args);
      default:
        return function() {
          return true;
        };
    }
  };
  window.generate_test = generateTest;
  generateExistTest = function(args) {
    return function() {
      try {
        return window.file_system.accessDirectory(args[0]) !== void 0;
      } catch (error) {
        return false;
      }
    };
  };
  generateHasTextTest = function(args) {
    return function() {
      return false;
    };
  };
  generateRanCommandTest = function(args) {
    return function() {
      return false;
    };
  };
  setInstructionText = function(text) {
    var formatted_text;
    if (typeof text === "string") {
      text = [text];
    }
    formatted_text = text.map(function(t) {
      return "<p>" + t + "</p>";
    }).join(" ");
    return $('#instructions').html(formatted_text);
  };
  window.observeLoop = observeLoop;
  window.initializeObserver = initializeObserver;
  window.observeReset = reset;
}).call(this);

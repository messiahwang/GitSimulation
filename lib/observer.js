(function() {
  var TUTORIAL, checkRule, generateExistTest, generateHasTextTest, generateRanCommandTest, generateTest, generateTests, initializeObserver, monitor, nextRule, observeLoop, prepareRule, reset;
  TUTORIAL = [
    {
      text: "run `git init` in bob's example_directory_1",
      rules: ["exists /home/bob/example_directory_1/.git"]
    }, {
      text: "run `git branch` anywhere within example_directory_1 to see your current branches",
      rules: ["ran_command git branch"]
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
      $('#instructions').text("You've cleared this tutorial! Congrats.. move on with your life");
      return clearInterval(window.observer.monitor_timer);
    }
  };
  prepareRule = function(item) {
    var text;
    text = item['text'];
    $('#instructions').text(text);
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
    var endpoint, path, wait_point;
    path = window.file_system.parsePathname(args[0]);
    endpoint = path.pop();
    wait_point = window.file_system.accessDirectory("/" + (path.join("/")));
    window.end = wait_point;
    window.tip = endpoint;
    window.wait = function() {
      return wait_point[endpoint] !== void 0;
    };
    return window.wait;
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
  window.observeLoop = observeLoop;
  window.initializeObserver = initializeObserver;
  window.observeReset = reset;
}).call(this);

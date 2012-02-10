(function() {
  var TUTORIAL, checkRule, generateTest, generateTests, initializeObserver, monitor, nextRule, observeLoop, prepareRule, reset;
  TUTORIAL = [
    {
      text: "run `git init` in bob's example_directory_1",
      rules: ["exists /home/bob/.git"],
      text: "run `git branch` anywhere within example_directory_1 to see your current branches",
      rules: ["ranCommand git branch"]
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
    console.log("monitoring");
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
      console.log("well.. yeah");
      return rule = prepareRule(tutorial[current_step]);
    } else {
      console.log("wut");
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
    return function() {
      return false;
    };
  };
  window.observeLoop = observeLoop;
  window.initializeObserver = initializeObserver;
  window.observeReset = reset;
  window.nextRule = nextRule;
}).call(this);

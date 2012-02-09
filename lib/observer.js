(function() {
  var TUTORIAL, checkRule, generateTests, monitor, nextRule, observeLoop, prepareRule;
  TUTORIAL = [
    {
      text: "run `git init` in bob's example_directory_1",
      rules: ["exists /home/bob/.git"],
      text: "run `git branch` anywhere within example_directory_1 to see your current branches",
      rules: ["ranCommand git branch"]
    }
  ];
  observeLoop = function() {
    var item;
    window.observer = {
      tests: [
        function() {
          return false;
        }
      ],
      current_step: 0,
      tutorial: TUTORIAL,
      monitor_timer: setInterval(monitor, 500)
    };
    item = window.observer.tutorial[window.observer.current_step];
    return prepareRule(item);
  };
  monitor = function() {
    console.log("monitoring");
    if (checkRule()) {
      return nextRule();
    }
  };
  nextRule = function() {
    var rule;
    window.observer.current_step += 1;
    if (!window.observer.current_step > window.observer.tutorial.length) {
      return rule = prepareRule();
    } else {
      console.log("cleared");
      return clearInterval(window.observer.monitor_timer);
    }
  };
  prepareRule = function(item) {
    var text;
    text = item['text'];
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
    return rules.map(function() {
      return function() {
        return true;
      };
    });
  };
  window.observeLoop = observeLoop;
}).call(this);

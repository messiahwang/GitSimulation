# Observer is used for the tutorial part of this app
# It watches the file system for changes to confirm
# that the user is doing as expected
#
# Observer language through YAML

# store multiple rules through a list

# Allowed Rules:
#   - exists <file>
#   - has_text <file>
#   - ran_command <Command>
TUTORIAL = [
  {
    text: "run `git init` in bob's example_directory_1"
    rules: ["exists /home/bob/example_directory_1/.git"]
  },
  {
    text: "run `git branch` anywhere within example_directory_1 to see your current branches"
    rules: ["ran_command git branch"]
  },
]

initializeObserver = () ->
  window.observer =
    tests: [() -> false]
    current_step: 0
    tutorial: TUTORIAL
  window.observer.nextRule = nextRule
  observeLoop()

observeLoop = () ->
  window.observer.monitor_timer = setInterval(monitor, 500)
  item = window.observer.tutorial[window.observer.current_step]
  prepareRule(item)

reset = () ->
  clearInterval(window.observer.monitor_timer)
  window.current_step = 0
  observeLoop()

monitor = () ->
  if checkRule()
    nextRule()

nextRule = () ->
  tutorial = window.observer.tutorial
  window.observer.current_step += 1
  current_step = window.observer.current_step
  if current_step < tutorial.length
    rule = prepareRule(tutorial[current_step])
  else
    $('#instructions').text("You've cleared this tutorial! Congrats.. move on with your life")
    clearInterval(window.observer.monitor_timer)

prepareRule = (item) ->
  text = item['text']
  $('#instructions').text(text)
  window.observer['tests'] = generateTests(item['rules'])

checkRule = () ->
  for test in window.observer['tests']
    if not test()
      return false
  true

# Builds tests out of the rules syntax
# An individual test should return true or false on if the condition is true
generateTests = (rules) ->
  return rules.map(generateTest)

generateTest = (rule) ->
  args = rule.split(/\ +/)
  type = args.shift()
  switch(type)
    when "exists"      then generateExistTest(args)
    when "has_text"    then generateHasTextTest(args)
    when "ran_command" then generateRanCommandTest(args)
    else () -> true

window.generate_test = generateTest

# args form should just be <file> or <dir> path.. with only one argument
generateExistTest = (args) ->
  path       = window.file_system.parsePathname(args[0])
  endpoint   = path.pop()
  wait_point = window.file_system.accessDirectory("/#{path.join("/")}")
  window.end = wait_point
  window.tip = endpoint
  window.wait = () -> wait_point[endpoint] != undefined
  window.wait


generateHasTextTest = (args) ->
  () -> false
generateRanCommandTest = (args) ->
  () -> false


window.observeLoop = observeLoop
window.initializeObserver = initializeObserver
window.observeReset = reset

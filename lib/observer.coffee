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
  text: "run `git init` in bob's example_directory_1"
  rules: ["exists /home/bob/.git"]
  ,
  text: "run `git branch` anywhere within example_directory_1 to see your current branches"
  rules: ["ranCommand git branch"]
]

initializeObserver = () ->
  window.observer =
    tests: [() -> false]
    current_step: 0
    tutorial: TUTORIAL
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
  console.log("monitoring")
  if checkRule()
    nextRule()

nextRule = () ->
  tutorial = window.observer.tutorial
  window.observer.current_step += 1
  current_step = window.observer.current_step
  if current_step < tutorial.length
    console.log("well.. yeah")
    rule = prepareRule(tutorial[current_step])
  else
    console.log("wut")
    $('#instructions').text("You've cleared this tutorial! Congrats.. move on with your life")
    clearInterval(window.observer.monitor_timer)

prepareRule = (item) ->
  text = item['text']
  # console.log(item)
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
  () -> false

window.observeLoop = observeLoop
window.initializeObserver = initializeObserver
window.observeReset = reset
window.nextRule = nextRule

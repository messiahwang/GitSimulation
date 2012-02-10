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
  window.observer.current_step += 1
  if not window.observer.current_step > window.observer.tutorial.length
    rule = prepareRule()
  else
    console.log("cleared")
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
  () -> true

window.observeLoop = observeLoop
window.initializeObserver = initializeObserver
window.observeReset = reset

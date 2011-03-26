exec = require('child_process').exec

process.env['PATH'] = "node_modules/.bin:#{process.env['PATH']}"

bold  = '\033[0;1m'
red   = '\033[0;31m'
green = '\033[0;32m'
reset = '\033[0m'

log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

onerror = (err) ->
  if err
    process.stdout.write "#{red}#{err.stack}#{reset}\n"
    process.exit -1

buildSteps = [
  [
    'Compiling CoffeeScript to JavaScript ...', (cb) ->
      exec 'rm -rf lib && coffee -c -b -o lib src', cb
  ],
  [
    'Copying dependencies ...', (cb) ->
      exec 'cp src/typhoon/feed.haml lib/typhoon/', cb
  ]
]

build = (cb) ->
  done = ->
    log 'Done!', green
  doStep = (i) ->
    return done() if i == buildSteps.length
    log buildSteps[i][0], green
    buildSteps[i][1] (err) ->
      cb err
      doStep i + 1
  doStep 0

task 'build', 'Build Typhoon', -> build onerror

clean = (cb) ->
  log 'Removing temporary files and current build', green
  exec 'rm -rf lib', cb

task 'clean', 'Remove temporary files and current build', -> clean onerror

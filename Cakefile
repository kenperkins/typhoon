{exec} = require 'child_process'
{series} = require 'async'

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

build = (cb) ->
  series [
    clean
    (cb) ->
      log 'Compiling CoffeeScript to Javascript', green
      exec 'coffee -c -b -o lib src', cb
    (cb) ->
      log 'Copying dependencies', green
      exec 'cp src/typhoon/feed.haml lib/typhoon/', cb
  ], cb

task 'build', 'Build Typhoon', -> build onerror

clean = (cb) ->
  log 'Removing temporary files and current build', green
  exec 'rm -rf lib', cb

task 'clean', 'Remove temporary files and current build', -> clean onerror

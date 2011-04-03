{exec} = require 'child_process'
{series} = require 'async'
fs = require 'fs'

process.env['PATH'] = "node_modules/.bin:#{process.env['PATH']}"

bold  = '\033[0;1m'
red   = '\033[0;31m'
green = '\033[0;32m'
reset = '\033[0m'

log = (message, color = green) -> console.log "#{color}#{message}#{reset}"

onerror = (err) ->
  if err
    process.stdout.write "#{red}#{err.stack}#{reset}\n"
    process.exit -1

build = (cb) ->
  compileCoffee = (cb) ->
    log 'Compiling CoffeeScript to Javascript'
    exec 'coffee -c -b -o lib src', cb

  copyDepends = (cb) ->
    log 'Copying dependencies'
    exec 'cp src/typhoon/feed.haml lib/typhoon/', cb

  series [
    clean
    compileCoffee
    copyDepends
  ], cb

task 'build', 'Build Typhoon', -> build onerror

clean = (cb) ->
  log 'Removing temporary files and current build'
  exec 'rm -rf lib', cb

task 'clean', 'Remove temporary files and current build', -> clean onerror

test = (cb) -> cb null

task 'test', 'Run all tests', -> test onerror

publish = (cb) ->
  npmPublish = (cb) ->
    log 'Publishing to NPM'
    exec 'npm publish', (err, stdout, stderr) ->
      log stdout
      cb err

  tagVersion = (cb) ->
    fs.readFile 'package.json', 'utf8', (err, package) ->
      onerror err
      package = JSON.parse package
      throw new Exception 'Invalid package.json' if !package.version
      log "Tagging v#{package.version}"
      exec "git tag v#{package.version}", (err, stdout, stderr) ->
        log stdout
        cb err

  pushGithub = (cb) ->
    exec 'git push --tag origin master', (err, stdout, stderr) ->
      log stdout
      cb err

  series [
    build
    test
    tagVersion
    pushGithub
    npmPublish
  ], cb

task 'publish', 'Prepare build and push new version to NPM', -> publish onerror

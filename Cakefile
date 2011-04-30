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

test = (cb) ->
  exec 'expresso -b test/*', (err, stdout, stderr) ->
    cb err
    matches = stderr.match /([0-9]+)% ([0-9]+) tests/
    cb new Error('Tests failed') if matches[1] != '100'
    log matches[0]

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
    test
    tagVersion
    pushGithub
    npmPublish
  ], cb

task 'publish', 'Prepare build and push new version to NPM', -> publish onerror

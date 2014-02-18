EventEmitter = require('events').EventEmitter
util = require '../lib/util'
colors = require 'colors'

defaults = {}
if !process.env.NODE_ENV || process.env.NODE_ENV is 'development'
  defaults.level = 3
else
  defaults.level = 0

defaults.catch = true

Logger = (options) ->
  if !(@ instanceof Logger)
    return new Logger options

  EventEmitter.call @

  util.extend defaults, options || {}
  @[key] = val for key, val of defaults

  return @

util.inherits Logger, EventEmitter

Logger::debug = (msg, info) ->
  if @level < 3
    return

  console.log colors.blue('DEBUG >> ') + msg, info || {}
  if @emit
    @emit 'debug', msg, info || {}

Logger::info = (msg, info) ->
  if @level < 2
    return

  console.log colors.green('INFO >> ') + msg, info || {}
  if @emit
    @emit 'info', msg, info || {}

Logger::warn = (msg, info) ->
  if @level < 1
    return

  console.log colors.yellow('WARN >> ') + msg, info || {}
  if @emit
    @emit 'warn', msg, info || {}

Logger::error = (msg, info) ->
  console.log colors.red('ERROR >> ') + msg, info || {}

  if !@catch and @emit
    @emit 'error', msg, info || {}

Logger::patch = (msg, info) ->
  console.log colors.cyan('PATCH >> ') + msg, info || {}

  if @emit
    @emit 'patch', msg, info || {}

module.exports = Logger

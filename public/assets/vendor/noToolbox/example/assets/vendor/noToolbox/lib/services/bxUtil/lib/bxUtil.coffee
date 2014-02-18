angular.module('bxUtil', [])

.service 'bxUtil', () ->

  # define some variables

  months = [
    'Jan', 'Feb', 'Mar',
    'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep',
    'Oct', 'Nov', 'Dec'
  ]

  formatRegExp = /%[sdj%]/g

  # # # # # # # # # #
  # # # # # # # # # #

  # define helper methods

  isArray = (ar) ->
    Array.isArray ar

  isBoolean = (arg) ->
    typeof arg is "boolean"

  isNull = (arg) ->
    arg is null

  isNullOrUndefined = (arg) ->
    not arg?

  isNumber = (arg) ->
    typeof arg is "number"

  isString = (arg) ->
    typeof arg is "string"

  isSymbol = (arg) ->
    typeof arg is "symbol"

  isUndefined = (arg) ->
    arg is undefined

  isRegExp = (re) ->
    isObject(re) and objectToString(re) is "[object RegExp]"

  isObject = (arg) ->
    typeof arg is "object" and arg

  isDate = (d) ->
    isObject(d) and objectToString(d) is "[object Date]"

  isError = (e) ->
    isObject(e) and objectToString(e) is "[object Error]"

  isFunction = (arg) ->
    typeof arg is "function"

  isPrimitive = (arg) ->
    # ES6 symbol
    return arg is null or typeof arg is "boolean" or typeof arg is "number" or
      typeof arg is "string" or typeof arg is "symbol" or
      typeof arg is "undefined"

  isBuffer = (arg) ->
    return arg and typeof arg is "object" and typeof arg.copy is "function" and
      typeof arg.fill is "function" and typeof arg.binarySlice is "function"


  # # # # # # # # # #
  # # # # # # # # # #

  format = (f) ->
    unless isString(f)
      objects = []
      i = 0

      while i < arguments.length
        objects.push inspect(arguments[i])
        i++
      return objects.join(" ")
    i = 1
    args = arguments
    len = args.length
    str = String(f).replace(formatRegExp, (x) ->
      return "%"  if x is "%%"
      return x  if i >= len
      switch x
        when "%s"
          String args[i++]
        when "%d"
          Number args[i++]
        when "%j"
          try
            return JSON.stringify(args[i++])
          catch _
            return "[Circular]"
        else
          x
    )
    x = args[i]

    while i < len
      if isNull(x) or not isObject(x)
        str += " " + x
      else
        str += " " + inspect(x)
      x = args[++i]
    str

  # # # # # # # # # #
  # # # # # # # # # #

  formatValue = (ctx, value, recurseTimes) ->

    # Provide a hook for user-specified inspect functions.
    # Check that value is an object with an inspect function on it

    # Filter out the util module, it's inspect function is special

    # Also filter out any prototype objects using the circular check.
    if ctx.customInspect and value and isFunction(value.inspect) and
    value.inspect isnt inspect and
    not (value.constructor and value.constructor:: is value)
      ret = value.inspect(recurseTimes)
      ret = formatValue(ctx, ret, recurseTimes)  unless isString(ret)
      return ret

    # Primitive types cannot have properties
    primitive = formatPrimitive(ctx, value)
    return primitive  if primitive

    # Look up the keys of the object.
    keys = shims.keys(value)
    visibleKeys = arrayToHash(keys)
    keys = shims.getOwnPropertyNames(value)  if ctx.showHidden

    # Some type of object without properties can be shortcutted.
    if keys.length is 0
      if isFunction(value)
        name = (if value.name then ": " + value.name else "")
        return ctx.stylize("[Function" + name + "]", "special")

      if isRegExp(value)
        return ctx.stylize(RegExp::toString.call(value), "regexp")

      if isDate(value)
        return ctx.stylize(Date::toString.call(value), "date")

      if isError(value)
        return formatError(value)

    base = ""
    array = false
    braces = ["{", "}"]

    # Make Array say that they are Array
    if isArray(value)
      array = true
      braces = ["[", "]"]

    # Make functions say that they are functions
    if isFunction(value)
      n = (if value.name then ": " + value.name else "")
      base = " [Function" + n + "]"

    # Make RegExps say that they are RegExps
    base = " " + RegExp::toString.call(value)  if isRegExp(value)

    # Make dates with properties first say the date
    base = " " + Date::toUTCString.call(value)  if isDate(value)

    # Make error with message first say the error
    base = " " + formatError(value)  if isError(value)
    if keys.length is 0 and (not array or value.length is 0)
      return braces[0] + base + braces[1]

    if recurseTimes < 0
      if isRegExp(value)
        return ctx.stylize(RegExp::toString.call(value), "regexp")
      else
        return ctx.stylize("[Object]", "special")
    ctx.seen.push value
    output = undefined
    if array
      output = formatArray(ctx, value, recurseTimes, visibleKeys, keys)
    else
      output = keys.map((key) ->
        formatProperty ctx, value, recurseTimes, visibleKeys, key, array
      )
    ctx.seen.pop()
    reduceToSingleString output, base, braces

  # # # # # # # # # #
  # # # # # # # # # #

  formatPrimitive = (ctx, value) ->
    return ctx.stylize("undefined", "undefined")  if isUndefined(value)
    if isString(value)
      simple = "'" + JSON.stringify(value).replace(/^"|"$/g, "")
      .replace(/'/g, "\\'").replace(/\\"/g, "\"") + "'"
      return ctx.stylize(simple, "string")
    return ctx.stylize("" + value, "number")  if isNumber(value)
    return ctx.stylize("" + value, "boolean")  if isBoolean(value)

    # For some reason typeof null is "object", so special case here.
    ctx.stylize "null", "null"  if isNull(value)

  # # # # # # # # # #
  # # # # # # # # # #

  formatError = (value) ->
    "[" + Error::toString.call(value) + "]"

  # # # # # # # # # #
  # # # # # # # # # #

  formatArray = (ctx, value, recurseTimes, visibleKeys, keys) ->
    output = []
    i = 0
    l = value.length

    while i < l
      if hasOwnProperty(value, String(i))
        f = formatProperty ctx, value, recurseTimes,
          visibleKeys, String(i), true

        output.push f
      else
        output.push ""
      ++i
    keys.forEach (key) ->
      if !key.match(/^\d+$/)
        f = formatProperty ctx, value, recurseTimes,
          visibleKeys, key, true

        output.push f
    return output

  # # # # # # # # # #
  # # # # # # # # # #

  formatProperty = (ctx, value, recurseTimes, visibleKeys, key, array) ->
    name = undefined
    str = undefined
    desc = undefined
    desc = Object.getOwnPropertyDescriptor(value, key) or value: value[key]
    if desc.get
      if desc.set
        str = ctx.stylize("[Getter/Setter]", "special")
      else
        str = ctx.stylize("[Getter]", "special")
    else
      str = ctx.stylize("[Setter]", "special")  if desc.set
    name = "[" + key + "]"  unless hasOwnProperty(visibleKeys, key)
    unless str
      if ctx.seen.indexOf(desc.value) < 0
        if isNull(recurseTimes)
          str = formatValue(ctx, desc.value, null)
        else
          str = formatValue(ctx, desc.value, recurseTimes - 1)
        if str.indexOf("\n") > -1
          if array
            str = str.split("\n").map((line) ->
              "  " + line
            ).join("\n").substr(2)
          else
            str = "\n" + str.split("\n").map((line) ->
              "   " + line
            ).join("\n")
      else
        str = ctx.stylize("[Circular]", "special")
    if isUndefined(name)
      return str  if array and key.match(/^\d+$/)
      name = JSON.stringify("" + key)
      if name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)
        name = name.substr(1, name.length - 2)
        name = ctx.stylize(name, "name")
      else
        name = name.replace(/'/g, "\\'").replace(/\\"/g, "\"")
        .replace(/(^"|"$)/g, "'")

        name = ctx.stylize(name, "string")
    name + ": " + str

  # # # # # # # # # #
  # # # # # # # # # #

  reduceToSingleString = (output, base, braces) ->
    numLinesEst = 0
    length = output.reduce((prev, cur) ->
      numLinesEst++
      numLinesEst++  if cur.indexOf("\n") >= 0
      prev + cur.replace(/\u001b\[\d\d?m/g, "").length + 1
    , 0)
    return braces[0] + ((if base is "" then "" else base + "\n ")) +
      " " + output.join(",\n  ") + " " + braces[1]  if length > 60
    braces[0] + base + " " + output.join(", ") + " " + braces[1]

  # # # # # # # # # #
  # # # # # # # # # #

  pad = (n) ->
    if n < 10
      return '0' + n.toString 10
    else
      return n.toString 10

  # # # # # # # # # #
  # # # # # # # # # #

  objectToString = (o) ->
    return Object.prototype.toString.call o

  # # # # # # # # # #
  # # # # # # # # # #

  stylizeWithColor = (str, styleType) ->
    style = inspect.styles[styleType]
    if style
      return "\u001b[" + inspect.colors[style][0] + "m" +
        str + "\u001b[" + inspect.colors[style][1] + "m"
    else
      return str

  stylizeNoColor = (str, styleType) ->
    return str

  # # # # # # # # # #
  # # # # # # # # # #

  inspect = (obj, opts) ->

    # default options
    ctx =
      seen: []
      stylize: stylizeNoColor


    # legacy...
    ctx.depth = arguments[2]  if arguments.length >= 3
    ctx.colors = arguments[3]  if arguments.length >= 4
    if isBoolean(opts)

      # legacy...
      ctx.showHidden = opts

    # got an "options" object
    else
      _extend ctx, opts  if opts

    # set default options
    ctx.showHidden = false  if isUndefined(ctx.showHidden)
    ctx.depth = 2  if isUndefined(ctx.depth)
    ctx.colors = false  if isUndefined(ctx.colors)
    ctx.customInspect = true  if isUndefined(ctx.customInspect)
    ctx.stylize = stylizeWithColor  if ctx.colors

    return formatValue ctx, obj, ctx.depth

  # http://en.wikipedia.org/wiki/ANSI_escape_code#graphics
  inspect.colors =
    bold: [1, 22]
    italic: [3, 23]
    underline: [4, 24]
    inverse: [7, 27]
    white: [37, 39]
    grey: [90, 39]
    black: [30, 39]
    blue: [34, 39]
    cyan: [36, 39]
    green: [32, 39]
    magenta: [35, 39]
    red: [31, 39]
    yellow: [33, 39]


  # Don't use 'blue' not visible on cmd.exe
  inspect.styles =
    special: "cyan"
    number: "yellow"
    boolean: "yellow"
    undefined: "grey"
    null: "bold"
    string: "green"
    date: "magenta"

    # "name": intentionally not styling
    regexp: "red"

  # # # # # # # # # #
  # # # # # # # # # #

  arrayToHash = (array) ->
    hash = {}
    array.forEach (val, idx) ->
      hash[val] = true

    hash

  # # # # # # # # # #
  # # # # # # # # # #

  inherits = (ctor, superCtor) ->
    ctor.super_ = superCtor
    ctor:: = Object.create superCtor::,
      constructor:
        value: ctor
        enumerable: false
        writeable: true
        configurable: true

  # # # # # # # # # #
  # # # # # # # # # #

  _extend = (one, two) ->
    # make sure valid objects
    return {} if !one
    return one if !two or typeof two isnt 'object'

    # get keys in object two
    keys = Object.keys two

    # iterate over keys, add to object one
    one[k] = two[k] for k in keys

    # return object
    return one

  # # # # # # # # # #
  # # # # # # # # # #

  log = () ->
    console.log '%s - $s', timestamp(), format.apply null, arguments

  # # # # # # # # # #
  # # # # # # # # # #

  random = (length) ->
    token = ''
    list = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklm' +
      'nopqrstuvwxyz0123456789'
    while token.length < length
      token += list.charAt(Math.floor(Math.random() * list.length))
    return token

  # # # # # # # # # #
  # # # # # # # # # #

  timestamp = () ->
    d = new Date()
    time = [
      pad(d.getHours())
      pad(d.getMinutes())
      pad(d.getSeconds())
    ].join(":")

    return [
      d.getDate()
      months[d.getMonth()]
      time
    ].join " "

  # # # # # # # # # #
  # # # # # # # # # #

  async = (fn) ->
    setTimeout ->
      fn
    , 0

  # # # # # # # # # #
  # # # # # # # # # #

  # expose methods

  isArray: isArray
  isBoolean: isBoolean
  isNull: isNull
  isNullOrUndefined: isNullOrUndefined
  isNumber: isNumber
  isString: isString
  isSymbol: isSymbol
  isUndefined: isUndefined
  isRegExp: isRegExp
  isObject: isObject
  isDate: isDate
  isError: isError
  isFunction: isFunction
  isPrimitive: isPrimitive
  isBuffer: isBuffer

  format: format
  formatValue: formatValue
  formatPrimitive: formatPrimitive
  formatError: formatError
  formatArray: formatArray
  formatProperty: formatProperty

  reduceToSingleString: reduceToSingleString

  pad: pad
  objectToString: objectToString
  stylizeWithColor: stylizeWithColor
  stylizeNoColor: stylizeNoColor
  inspect: inspect
  arrayToHash: arrayToHash
  inherits: inherits
  extend: _extend
  log: log
  random: random
  timestamp: timestamp
  async: async

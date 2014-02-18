angular.module('bxUtil', []).service('bxUtil', function() {
  var arrayToHash, async, format, formatArray, formatError, formatPrimitive, formatProperty, formatRegExp, formatValue, inherits, inspect, isArray, isBoolean, isBuffer, isDate, isError, isFunction, isNull, isNullOrUndefined, isNumber, isObject, isPrimitive, isRegExp, isString, isSymbol, isUndefined, log, months, objectToString, pad, random, reduceToSingleString, stylizeNoColor, stylizeWithColor, timestamp, _extend;
  months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  formatRegExp = /%[sdj%]/g;
  isArray = function(ar) {
    return Array.isArray(ar);
  };
  isBoolean = function(arg) {
    return typeof arg === "boolean";
  };
  isNull = function(arg) {
    return arg === null;
  };
  isNullOrUndefined = function(arg) {
    return arg == null;
  };
  isNumber = function(arg) {
    return typeof arg === "number";
  };
  isString = function(arg) {
    return typeof arg === "string";
  };
  isSymbol = function(arg) {
    return typeof arg === "symbol";
  };
  isUndefined = function(arg) {
    return arg === void 0;
  };
  isRegExp = function(re) {
    return isObject(re) && objectToString(re) === "[object RegExp]";
  };
  isObject = function(arg) {
    return typeof arg === "object" && arg;
  };
  isDate = function(d) {
    return isObject(d) && objectToString(d) === "[object Date]";
  };
  isError = function(e) {
    return isObject(e) && objectToString(e) === "[object Error]";
  };
  isFunction = function(arg) {
    return typeof arg === "function";
  };
  isPrimitive = function(arg) {
    return arg === null || typeof arg === "boolean" || typeof arg === "number" || typeof arg === "string" || typeof arg === "symbol" || typeof arg === "undefined";
  };
  isBuffer = function(arg) {
    return arg && typeof arg === "object" && typeof arg.copy === "function" && typeof arg.fill === "function" && typeof arg.binarySlice === "function";
  };
  format = function(f) {
    var args, i, len, objects, str, x;
    if (!isString(f)) {
      objects = [];
      i = 0;
      while (i < arguments.length) {
        objects.push(inspect(arguments[i]));
        i++;
      }
      return objects.join(" ");
    }
    i = 1;
    args = arguments;
    len = args.length;
    str = String(f).replace(formatRegExp, function(x) {
      var _;
      if (x === "%%") {
        return "%";
      }
      if (i >= len) {
        return x;
      }
      switch (x) {
        case "%s":
          return String(args[i++]);
        case "%d":
          return Number(args[i++]);
        case "%j":
          try {
            return JSON.stringify(args[i++]);
          } catch (_error) {
            _ = _error;
            return "[Circular]";
          }
          break;
        default:
          return x;
      }
    });
    x = args[i];
    while (i < len) {
      if (isNull(x) || !isObject(x)) {
        str += " " + x;
      } else {
        str += " " + inspect(x);
      }
      x = args[++i];
    }
    return str;
  };
  formatValue = function(ctx, value, recurseTimes) {
    var array, base, braces, keys, n, name, output, primitive, ret, visibleKeys;
    if (ctx.customInspect && value && isFunction(value.inspect) && value.inspect !== inspect && !(value.constructor && value.constructor.prototype.is(value))) {
      ret = value.inspect(recurseTimes);
      if (!isString(ret)) {
        ret = formatValue(ctx, ret, recurseTimes);
      }
      return ret;
    }
    primitive = formatPrimitive(ctx, value);
    if (primitive) {
      return primitive;
    }
    keys = shims.keys(value);
    visibleKeys = arrayToHash(keys);
    if (ctx.showHidden) {
      keys = shims.getOwnPropertyNames(value);
    }
    if (keys.length === 0) {
      if (isFunction(value)) {
        name = (value.name ? ": " + value.name : "");
        return ctx.stylize("[Function" + name + "]", "special");
      }
      if (isRegExp(value)) {
        return ctx.stylize(RegExp.prototype.toString.call(value), "regexp");
      }
      if (isDate(value)) {
        return ctx.stylize(Date.prototype.toString.call(value), "date");
      }
      if (isError(value)) {
        return formatError(value);
      }
    }
    base = "";
    array = false;
    braces = ["{", "}"];
    if (isArray(value)) {
      array = true;
      braces = ["[", "]"];
    }
    if (isFunction(value)) {
      n = (value.name ? ": " + value.name : "");
      base = " [Function" + n + "]";
    }
    if (isRegExp(value)) {
      base = " " + RegExp.prototype.toString.call(value);
    }
    if (isDate(value)) {
      base = " " + Date.prototype.toUTCString.call(value);
    }
    if (isError(value)) {
      base = " " + formatError(value);
    }
    if (keys.length === 0 && (!array || value.length === 0)) {
      return braces[0] + base + braces[1];
    }
    if (recurseTimes < 0) {
      if (isRegExp(value)) {
        return ctx.stylize(RegExp.prototype.toString.call(value), "regexp");
      } else {
        return ctx.stylize("[Object]", "special");
      }
    }
    ctx.seen.push(value);
    output = void 0;
    if (array) {
      output = formatArray(ctx, value, recurseTimes, visibleKeys, keys);
    } else {
      output = keys.map(function(key) {
        return formatProperty(ctx, value, recurseTimes, visibleKeys, key, array);
      });
    }
    ctx.seen.pop();
    return reduceToSingleString(output, base, braces);
  };
  formatPrimitive = function(ctx, value) {
    var simple;
    if (isUndefined(value)) {
      return ctx.stylize("undefined", "undefined");
    }
    if (isString(value)) {
      simple = "'" + JSON.stringify(value).replace(/^"|"$/g, "").replace(/'/g, "\\'").replace(/\\"/g, "\"") + "'";
      return ctx.stylize(simple, "string");
    }
    if (isNumber(value)) {
      return ctx.stylize("" + value, "number");
    }
    if (isBoolean(value)) {
      return ctx.stylize("" + value, "boolean");
    }
    if (isNull(value)) {
      return ctx.stylize("null", "null");
    }
  };
  formatError = function(value) {
    return "[" + Error.prototype.toString.call(value) + "]";
  };
  formatArray = function(ctx, value, recurseTimes, visibleKeys, keys) {
    var f, i, l, output;
    output = [];
    i = 0;
    l = value.length;
    while (i < l) {
      if (hasOwnProperty(value, String(i))) {
        f = formatProperty(ctx, value, recurseTimes, visibleKeys, String(i), true);
        output.push(f);
      } else {
        output.push("");
      }
      ++i;
    }
    keys.forEach(function(key) {
      if (!key.match(/^\d+$/)) {
        f = formatProperty(ctx, value, recurseTimes, visibleKeys, key, true);
        return output.push(f);
      }
    });
    return output;
  };
  formatProperty = function(ctx, value, recurseTimes, visibleKeys, key, array) {
    var desc, name, str;
    name = void 0;
    str = void 0;
    desc = void 0;
    desc = Object.getOwnPropertyDescriptor(value, key) || {
      value: value[key]
    };
    if (desc.get) {
      if (desc.set) {
        str = ctx.stylize("[Getter/Setter]", "special");
      } else {
        str = ctx.stylize("[Getter]", "special");
      }
    } else {
      if (desc.set) {
        str = ctx.stylize("[Setter]", "special");
      }
    }
    if (!hasOwnProperty(visibleKeys, key)) {
      name = "[" + key + "]";
    }
    if (!str) {
      if (ctx.seen.indexOf(desc.value) < 0) {
        if (isNull(recurseTimes)) {
          str = formatValue(ctx, desc.value, null);
        } else {
          str = formatValue(ctx, desc.value, recurseTimes - 1);
        }
        if (str.indexOf("\n") > -1) {
          if (array) {
            str = str.split("\n").map(function(line) {
              return "  " + line;
            }).join("\n").substr(2);
          } else {
            str = "\n" + str.split("\n").map(function(line) {
              return "   " + line;
            }).join("\n");
          }
        }
      } else {
        str = ctx.stylize("[Circular]", "special");
      }
    }
    if (isUndefined(name)) {
      if (array && key.match(/^\d+$/)) {
        return str;
      }
      name = JSON.stringify("" + key);
      if (name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)) {
        name = name.substr(1, name.length - 2);
        name = ctx.stylize(name, "name");
      } else {
        name = name.replace(/'/g, "\\'").replace(/\\"/g, "\"").replace(/(^"|"$)/g, "'");
        name = ctx.stylize(name, "string");
      }
    }
    return name + ": " + str;
  };
  reduceToSingleString = function(output, base, braces) {
    var length, numLinesEst;
    numLinesEst = 0;
    length = output.reduce(function(prev, cur) {
      numLinesEst++;
      if (cur.indexOf("\n") >= 0) {
        numLinesEst++;
      }
      return prev + cur.replace(/\u001b\[\d\d?m/g, "").length + 1;
    }, 0);
    if (length > 60) {
      return braces[0] + (base === "" ? "" : base + "\n ") + " " + output.join(",\n  ") + " " + braces[1];
    }
    return braces[0] + base + " " + output.join(", ") + " " + braces[1];
  };
  pad = function(n) {
    if (n < 10) {
      return '0' + n.toString(10);
    } else {
      return n.toString(10);
    }
  };
  objectToString = function(o) {
    return Object.prototype.toString.call(o);
  };
  stylizeWithColor = function(str, styleType) {
    var style;
    style = inspect.styles[styleType];
    if (style) {
      return "\u001b[" + inspect.colors[style][0] + "m" + str + "\u001b[" + inspect.colors[style][1] + "m";
    } else {
      return str;
    }
  };
  stylizeNoColor = function(str, styleType) {
    return str;
  };
  inspect = function(obj, opts) {
    var ctx;
    ctx = {
      seen: [],
      stylize: stylizeNoColor
    };
    if (arguments.length >= 3) {
      ctx.depth = arguments[2];
    }
    if (arguments.length >= 4) {
      ctx.colors = arguments[3];
    }
    if (isBoolean(opts)) {
      ctx.showHidden = opts;
    } else {
      if (opts) {
        _extend(ctx, opts);
      }
    }
    if (isUndefined(ctx.showHidden)) {
      ctx.showHidden = false;
    }
    if (isUndefined(ctx.depth)) {
      ctx.depth = 2;
    }
    if (isUndefined(ctx.colors)) {
      ctx.colors = false;
    }
    if (isUndefined(ctx.customInspect)) {
      ctx.customInspect = true;
    }
    if (ctx.colors) {
      ctx.stylize = stylizeWithColor;
    }
    return formatValue(ctx, obj, ctx.depth);
  };
  inspect.colors = {
    bold: [1, 22],
    italic: [3, 23],
    underline: [4, 24],
    inverse: [7, 27],
    white: [37, 39],
    grey: [90, 39],
    black: [30, 39],
    blue: [34, 39],
    cyan: [36, 39],
    green: [32, 39],
    magenta: [35, 39],
    red: [31, 39],
    yellow: [33, 39]
  };
  inspect.styles = {
    special: "cyan",
    number: "yellow",
    boolean: "yellow",
    undefined: "grey",
    "null": "bold",
    string: "green",
    date: "magenta",
    regexp: "red"
  };
  arrayToHash = function(array) {
    var hash;
    hash = {};
    array.forEach(function(val, idx) {
      return hash[val] = true;
    });
    return hash;
  };
  inherits = function(ctor, superCtor) {
    ctor.super_ = superCtor;
    return ctor.prototype = Object.create(superCtor.prototype, {
      constructor: {
        value: ctor,
        enumerable: false,
        writeable: true,
        configurable: true
      }
    });
  };
  _extend = function(one, two) {
    var k, keys, _i, _len;
    if (!one) {
      return {};
    }
    if (!two || typeof two !== 'object') {
      return one;
    }
    keys = Object.keys(two);
    for (_i = 0, _len = keys.length; _i < _len; _i++) {
      k = keys[_i];
      one[k] = two[k];
    }
    return one;
  };
  log = function() {
    return console.log('%s - $s', timestamp(), format.apply(null, arguments));
  };
  random = function(length) {
    var list, token;
    token = '';
    list = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklm' + 'nopqrstuvwxyz0123456789';
    while (token.length < length) {
      token += list.charAt(Math.floor(Math.random() * list.length));
    }
    return token;
  };
  timestamp = function() {
    var d, time;
    d = new Date();
    time = [pad(d.getHours()), pad(d.getMinutes()), pad(d.getSeconds())].join(":");
    return [d.getDate(), months[d.getMonth()], time].join(" ");
  };
  async = function(fn) {
    return setTimeout(function() {
      return fn;
    }, 0);
  };
  return {
    isArray: isArray,
    isBoolean: isBoolean,
    isNull: isNull,
    isNullOrUndefined: isNullOrUndefined,
    isNumber: isNumber,
    isString: isString,
    isSymbol: isSymbol,
    isUndefined: isUndefined,
    isRegExp: isRegExp,
    isObject: isObject,
    isDate: isDate,
    isError: isError,
    isFunction: isFunction,
    isPrimitive: isPrimitive,
    isBuffer: isBuffer,
    format: format,
    formatValue: formatValue,
    formatPrimitive: formatPrimitive,
    formatError: formatError,
    formatArray: formatArray,
    formatProperty: formatProperty,
    reduceToSingleString: reduceToSingleString,
    pad: pad,
    objectToString: objectToString,
    stylizeWithColor: stylizeWithColor,
    stylizeNoColor: stylizeNoColor,
    inspect: inspect,
    arrayToHash: arrayToHash,
    inherits: inherits,
    _extend: _extend,
    log: log,
    random: random,
    timestamp: timestamp,
    async: async
  };
});

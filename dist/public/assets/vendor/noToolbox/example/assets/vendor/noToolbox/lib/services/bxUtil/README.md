bxUtil
====

NodeJS util package (as well as some extra useful functions) ported into an AngularJS module (service).
<br />
Smarter Javascript for the browser.


##Functions include:

- isArray
- isBoolean
- isNull
- isNullOrUndefined
- isNumber
- isString
- isSymbol
- isUndefined
- isRegExp
- isObject
- isDate
- isError
- isFunction
- isPrimitive
- isBuffer
- format
- formatValue
- formatPrimitive
- formatError
- formatArray
- formatProperty
- reduceToSingleString
- pad
- objectToString
- stylizeWithColor
- stylizeNoColor
- inspect
- arrayToHash
- inherits
- _extend
- log
- random
- timestamp
- async

<br />

## Usage

1. Clone the repo into your project.
2. Add `dist/bxUtil.js` to the head of your project.
3. Bootstrap the bxUtil module to your Angular module like so:

<pre>
angular.boostrap('YourModule', [ 'bxUtil' ]);
</pre>

Now you can require the bxUtil service in any of your modules and call any of its functions directly.

<pre>
YourModule.service('YourService', [ 'bxUtil', function(bxUtil) {
  console.log (bxUtil.random(10) ); // prints out a random string with 10 characters
  console.log (bxUtil.isFunction('foobar') ); // false
}])
</pre>

###Notes
Developed by <a href='http://twitter.com/ishmaelsalive'>Ishmael tD</a>. <br />
Special thanks to all the vendors who've created all the third party libraries this seed relies on. <br />

Feedback, suggestions? Tweet me <a href='http://twitter.com/ishmaelsalive'>@IshmaelsAlive</a>. <br />
Need some personal help? Email me @ <a href='mailto:ishmaelthedestroyer@gmail.com?Subject=LazyNMean'>ishmaelthedestroyer@gmail.com</a>

<br />

###License
Licensed under the MIT license. tl;dr You can do whatever you want with it.

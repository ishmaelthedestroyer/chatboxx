// basic express app
var express = require('express');
var app = express();

// set static folder to serve assets from
app.use(express.static(__dirname));

// serve all requests to index.html in public folder
app.get('*', function(req, res) {
  res.sendfile(__dirname + '/example/index.html');
});

// listen
port = process.env.PORT || process.argv[2] || 8888;
app.listen(port);

console.log('Static socket server listening on port ' + port + '.');

var Logger, app, appCONFIG, argv, cluster, express, fs, i, io, keepAlive, numCPUs, options, path, port, server, worker;

argv = require('optimist').argv;

express = require('express');

app = express();

if ((argv.environment != null) && argv.environment === 'production') {
  process.env.NODE_ENV = 'production';
} else {
  process.env.NODE_ENV = 'development';
}

if ((argv.useSSL != null) && argv.useSSL === 'true') {
  process.env.useSSL = true;
} else {
  process.env.useSSL = false;
}

Logger = new (require('./lib/logger'));

cluster = require('cluster');

numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
  i = 0;
  while (i < numCPUs) {
    worker = cluster.fork();
    Logger.info('Worker #' + worker.id + ' with pid ' + worker.process.pid + ' was created.');
    ++i;
  }
  cluster.on('exit', function(worker, code, signal) {
    var msg, newWorker;
    newWorker = cluster.fork();
    msg = 'Worker #' + worker.id + ' with pid ' + worker.process.pid + ' died.';
    msg += 'Worker #' + newWorker.id + ' with pid ' + newWorker.process.pid + ' was created.';
    return Logger.info(msg);
  });
  if (process.env.NODE_ENV === 'production') {
    keepAlive = require('./lib/keep-alive');
    keepAlive.run();
  }
} else {
  require('./config/app/express')(app);
  if (process.env.useSSL === true) {
    app.all('*', function(req, res, next) {
      var p;
      if (process.env.NODE_ENV === 'development') {
        if (!req.secure) {
          p = process.env.PORT || appCONFIG.port || 3000;
          return res.redirect('https://localhost:' + p + req.url);
        }
      } else {
        if ((req.headers['x-forwarded-proto'] || '').toLowerCase() !== 'https') {
          return res.redirect('https://' + req.headers.host + req.url);
        }
      }
      return next();
    });
  }
  require('./config/app/routes')(app);
  if (process.env.NODE_ENV === 'development' && process.env.useSSL === true) {
    Logger.debug('useSSL: ' + process.env.useSSL);
    path = require('path');
    fs = require('fs');
    options = {
      key: fs.readFileSync(path.resolve(__dirname + '/config/ssl/local/localhost.pem')),
      cert: fs.readFileSync(path.resolve(__dirname + '/config/ssl/local/certificate.pem'))
    };
    server = require('https').createServer(options, app);
  } else {
    server = require('http').createServer(app);
  }
  io = require('./config/app/io')(server);
  require('./app/controllers/socket')(io);
  appCONFIG = require('./config/env/app');
  port = process.env.PORT || appCONFIG.port || 3000;
  if (process.env.NODE_ENV === 'development') {
    server.listen(port, '0.0.0.0');
  } else {
    server.listen(port);
  }
  Logger.debug(appCONFIG.name + ' listening on port ' + port + ' (' + process.env.NODE_ENV + ').');
}

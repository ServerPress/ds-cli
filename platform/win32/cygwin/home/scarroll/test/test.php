<?php
  $loader = require __DIR__ . '/vendor/autoload.php';
  $loader->add('Acme\\Test\\', __DIR__);
  $log = new Monolog\Logger('name');
  $log->pushHandler(new Monolog\Handler\StreamHandler('app.log', Monolog\Logger::WARNING));
  $log->addWarning('Foo');

#!/usr/bin/env bash

#Name: qwiklabsDemo
#Trigger: HTTP
#Authentication: check the box next to Allow unauthenticated invocations
#Index.js tab: replace the placeholder code with the following:
#/**
# *   Cloud Function.
# *
# *
# */
#exports.qwiklabsDemo = function qwiklabsDemo (req, res) {
#  res.send(`Hello ${req.body.name || 'World'}!`);
#  console.log(req.body.name);
#}

wget 'https://github.com/tsenart/vegeta/releases/download/v6.3.0/vegeta-v6.3.0-linux-386.tar.gz'
tar xvzf vegeta-v6.3.0-linux-386.tar.gz

#!/usr/bin/env bash

git clone https://github.com/GoogleCloudPlatform/nodejs-docs-samples.git && cd nodejs-docs-samples/appengine/hello-world/flexible || exit 1
npm install
npm start

# app.yaml
runtime: nodejs
env: flex

npm install uuid --save
vi app.js

# app.js
#'use strict';
#
#// [START gae_flex_quickstart]
#const express = require('express');
#const { v4: uuid } = require('uuid');
#
#const app = express();
#
#app.get('/', (req, res) => {
#  res
#    .status(200)
#    .send(`Hello, ${uuid()}!`)
#    .end();
#});
#
#// Start the server
#const PORT = process.env.PORT || 8080;
#app.listen(PORT, () => {
#  console.log(`App listening on port ${PORT}`);
#  console.log('Press Ctrl+C to quit.');
#});
#// [END gae_flex_quickstart]
npm start
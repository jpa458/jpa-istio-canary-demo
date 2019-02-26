'use strict';

const express = require('express');
const path = require('path');

// Constants
const PORT = 9080;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/webserver', (req, res) => {
  res.send('<html><body style="background-color: blue"><body></html>');
});

app.get('/demo', function(req, res) {
    res.sendFile(path.join(__dirname + '/demo.html'));
});



app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

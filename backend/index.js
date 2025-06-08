// backend/index.js

const express = require('express');
const app = express();

// This is a requirement for Cloud Run: it looks for the "PORT" environment variable
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
    res.send('Hello from the Soccer Site API!');
});

app.listen(port, () => {
    console.log(`API server listening on port ${port}`);
});
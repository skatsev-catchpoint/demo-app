const express = require('express');
const cors = require('cors');

const app = express();

const port = 3000;

app.use(cors()); // Enable CORS for all routes

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log('Backend is running at http://localhost:${port}');
});

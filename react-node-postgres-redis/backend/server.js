const express = require("express");
const { Pool } = require("pg");
const redis = require("redis");

const app = express();
const port = 3000;

const pool = new Pool({
  user: 'myuser',
  host: 'db',
  database: 'mydatabase',
  password: 'mypassword',
  port: 5432,
});

const redisClient = redis.createClient({
  host: 'redis',
  port: 6379,
});

app.get("/", (req, res) => {
  res.send("Hello from Node.js backend");
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});

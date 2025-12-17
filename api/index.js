const express = require("express");
const { Client } = require("pg");

const app = express();
const PORT = process.env.PORT || 3000;

const dbConfig = {
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: { rejectUnauthorized: false },
};

let dbStatus = { connected: false, lastError: null };

async function initDb() {
  try {
    const client = new Client(dbConfig);
    await client.connect();
    await client.query("select 1");
    await client.end();
    dbStatus = { connected: true, lastError: null };
  } catch (e) {
    dbStatus = { connected: false, lastError: e.message };
  }
}

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "heavy-api",
    time: new Date().toISOString(),
    db: dbStatus,
  });
});

app.listen(PORT, () => {
  console.log("API started");
  initDb();
});


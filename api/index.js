const express = require("express");
const { Client } = require("pg");

const app = express();

const PORT = process.env.PORT || 3000;
const dbConfig = {
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: {
    rejectUnauthorized: false,
  },
};


let dbStatus = {
  connected: false,
  lastError: null,
};

async function initDb() {
  console.log("Connecting to PostgreSQL with config:", {
    host: dbConfig.host,
    database: dbConfig.database,
    user: dbConfig.user,
  });

  const client = new Client(dbConfig);

  try {
    await client.connect();
    dbStatus.connected = true;
    dbStatus.lastError = null;

    console.log("✅ Connected to PostgreSQL");

    await client.query("CREATE TABLE IF NOT EXISTS health_check (id SERIAL PRIMARY KEY, created_at TIMESTAMP DEFAULT NOW())");

    await client.query("INSERT INTO health_check DEFAULT VALUES");

    await client.end();
  } catch (err) {
    dbStatus.connected = false;
    dbStatus.lastError = err.message;
    console.error("❌ Error connecting to PostgreSQL:", err.message);
  }
}

app.get("/health", (req, res) => {
  res.json({
        status: "ok",
    service: "heavy-api-v2",

    time: new Date().toISOString(),
    db: dbStatus,
  });
});

app.listen(PORT, () => {
  console.log(`API listening on port ${PORT}`);
  initDb();
});


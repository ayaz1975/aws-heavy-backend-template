const { Client } = require("pg");

const dbConfig = {
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
};

console.log("Worker starting with DB config:", {
  host: dbConfig.host,
  database: dbConfig.database,
  user: dbConfig.user,
});

async function doWork() {
  const client = new Client(dbConfig);

  try {
    await client.connect();
    console.log("✅ Worker connected to PostgreSQL");

    await client.query(`
      CREATE TABLE IF NOT EXISTS worker_jobs (
        id SERIAL PRIMARY KEY,
        created_at TIMESTAMP DEFAULT NOW(),
        info TEXT
      )
    `);

    await client.query(
      "INSERT INTO worker_jobs (info) VALUES ($1)",
      [`Worker job at ${new Date().toISOString()}`]
    );

    console.log("✅ Worker inserted job row");
    await client.end();
  } catch (err) {
    console.error("❌ Worker error:", err.message);
  }
}

setInterval(() => {
  console.log("Worker tick:", new Date().toISOString());
  doWork();
}, 30000);

doWork();


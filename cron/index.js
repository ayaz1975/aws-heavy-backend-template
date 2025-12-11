const { Client } = require("pg");

const dbConfig = {
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
};

console.log("Cron job starting with DB config:", {
  host: dbConfig.host,
  database: dbConfig.database,
  user: dbConfig.user,
});

async function runCronJob() {
  const client = new Client(dbConfig);

  try {
    await client.connect();
    console.log("✅ Cron connected to PostgreSQL");

    await client.query(`
      CREATE TABLE IF NOT EXISTS cron_logs (
        id SERIAL PRIMARY KEY,
        created_at TIMESTAMP DEFAULT NOW(),
        info TEXT
      )
    `);

    await client.query(
      "INSERT INTO cron_logs (info) VALUES ($1)",
      [`Cron run at ${new Date().toISOString()}`]
    );

    console.log("✅ Cron inserted log row");
    await client.end();
  } catch (err) {
    console.error("❌ Cron error:", err.message);
  } finally {
    console.log("Cron job finished, exiting.");
    process.exit(0);
  }
}

runCronJob();


const express = require("express");
const routes = require("./routes");
const initDB = require("./initDB");

const app = express();

app.use(express.json({ limit: "1mb" }));

// Health check for ALB
app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.use("/api", routes);


// Global error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: "Internal server error" });
});


async function start() {
  await initDB();

  const port = process.env.PORT || 3000;

  app.listen(port, () => {
    console.log(`Backend running on port ${port}`);
  });
}

start();
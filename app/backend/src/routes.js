const express = require("express");
const Joi = require("joi");
const pool = require("./db");

const router = express.Router();

const schema = Joi.object({
  name: Joi.string().min(3).max(100).required(),
  email: Joi.string().email().required()
});


// CREATE
router.post("/users", async (req, res) => {
  try {
    const { error } = schema.validate(req.body);
    if (error) return res.status(400).json({ error: error.details });

    const { name, email } = req.body;

    await pool.execute(
      "INSERT INTO users (name, email) VALUES (?, ?)",
      [name, email]
    );

    res.json({ message: "User created" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});


// READ
router.get("/users", async (req, res) => {
  try {
    const [rows] = await pool.execute("SELECT * FROM users");
    res.json(rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});


// UPDATE
router.put("/users/:id", async (req, res) => {
  try {
    const { error } = schema.validate(req.body);
    if (error) return res.status(400).json({ error: error.details });

    const { name, email } = req.body;

    await pool.execute(
      "UPDATE users SET name = ?, email = ? WHERE id = ?",
      [name, email, req.params.id]
    );

    res.json({ message: "User updated" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});


// DELETE
router.delete("/users/:id", async (req, res) => {
  try {
    await pool.execute(
      "DELETE FROM users WHERE id = ?",
      [req.params.id]
    );

    res.json({ message: "User deleted" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

module.exports = router;
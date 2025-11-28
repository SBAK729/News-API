import dotenv from "dotenv";
import express from "express";
import {connectDB} from "./config/db.js";

import authRoutes from "./routes/authRoutes.js";
import newsRoutes from "./routes/newsRoutes.js";

dotenv.config();
const app = express();

app.use(express.json());

connectDB();

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/news", newsRoutes);

app.listen(8000, () => console.log("Server running on port 8000"));

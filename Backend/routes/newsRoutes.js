import express from "express";
import { auth } from "../middleware/auth.js";
import axios from "axios";

const router = express.Router();

// Get news from NewsData API with filters

router.get("/newsdata", auth, async (req, res) => {
  try {
    const apiKey = process.env.NEWS_DATA_API_KEY;

    if (!apiKey) {
      return res.status(500).json({ msg: "NewsData API key missing" });
    }

    const filters = req.query;

    const response = await axios.get("https://newsdata.io/api/1/latest", {
      params: {
        apikey: process.env.NEWS_DATA_API_KEY,
        ...filters,
      },
    });

    const data = await response.data;

    if (!data.results) {
      return res.status(500).json({ msg: "Failed to fetch news", data });
    }

    res.json({
      message: "Fetched news successfully",
      news: data.results,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ msg: "Server Error", error: error.message });
  }
});

export default router;

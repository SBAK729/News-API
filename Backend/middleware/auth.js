import jwt from "jsonwebtoken";
import blacklist from "../utils/tokenBlacklist.js";

// JWT Authentication Middleware
export const auth = (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];

  if (!token)
    return res.status(401).json({ msg: "Please Login to access Resource!" });

  if (blacklist.isBlacklisted(token)) {
    return res.status(401).json({ msg: "Invalid Token!!!" });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ msg: "Token is not valid" });
  }
};

import express from "express";
import authRoutes from "./routes/authRoutes.js";
import { errorHandler, notFound } from "./middleware/errorHandler.js";

const app = express();
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});


app.use("/api/auth", authRoutes);


app.use(notFound);
app.use(errorHandler);

export default app;

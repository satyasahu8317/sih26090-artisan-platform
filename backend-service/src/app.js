import express from "express";
import authRoutes from "./routes/authRoutes.js";
import { errorHandler, notFound } from "./middleware/errorHandler.js";

const app = express();
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});


import aiRoutes from "./routes/aiRoutes.js";
import artisanRoutes from "./routes/artisanRoutes.js";
import productRoutes from "./routes/productRoutes.js";
import notificationRoutes from "./routes/notificationRoutes.js";

app.use("/api/auth", authRoutes);
app.use("/api/v1/ai", aiRoutes);
app.use("/api/v1/artisans", artisanRoutes);
app.use("/api/v1/products", productRoutes);
app.use("/api/v1/notifications", notificationRoutes);

app.use(notFound);
app.use(errorHandler);

export default app;

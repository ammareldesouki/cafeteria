import "@config/env";
import app from "./app";
import { connectDB } from "@config/db";
import { PORT } from "@config/env";

const start = async () => {
  await connectDB();

  const server = app.listen(PORT || 3001, () => {
    console.log(`🚀 Server running on port ${PORT || 3001}`);
  });

  ["SIGINT", "SIGTERM"].forEach((signal) => {
    process.on(signal, () => {
      console.log(`Received ${signal}, closing server...`);
      server.close(() => process.exit(0));
    });
  });
};

start().catch((err) => {
  console.error("❌ Server startup error:", err);
  process.exit(1);
});
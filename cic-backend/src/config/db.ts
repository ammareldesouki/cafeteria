import mongoose from "mongoose";
import { DATABASE_URL } from "@config/env";

if (!DATABASE_URL) {
	throw new Error("DATABASE_URL is not defined");
}

export const connectDB = async () => {
	try {
		await mongoose.connect(DATABASE_URL);
		console.log("MongoDB connected");
	} catch (error) {
		console.error("MongoDB connection error:", error);
		process.exit(1);
	}
};

import mongoose from "mongoose";
import { OTP } from "@/types/auth.types";

const collection = mongoose.connection.collection<OTP>("otps");

export const otpRepository = {
	async create(otp: OTP): Promise<OTP> {
		const result = await collection.insertOne(otp);
		return { ...otp, _id: result.insertedId };
	},

	async findValidOTP(email: string, code: string, type: OTP["type"]): Promise<OTP | null> {
		return collection.findOne({
			email,
			code,
			type,
			expiresAt: { $gt: new Date() },
		}) as Promise<OTP | null>;
	},

	async deleteByEmail(email: string, type: OTP["type"]): Promise<void> {
		await collection.deleteMany({ email, type });
	},
};

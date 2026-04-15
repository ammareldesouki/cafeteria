import mongoose from "mongoose";

type CafeteriaSettingsDocument = {
	_id: string;
	callNumber: string;
};

const collection =
	mongoose.connection.collection<CafeteriaSettingsDocument>("cafeteria_no");

export const cafeteriaSettingsRepository = {
	async getCallNumber(): Promise<string | null> {
		const doc = await collection.findOne({
			_id: "default",
		});

		return doc?.callNumber ?? null;
	},

	async setCallNumber(callNumber: string): Promise<string> {
		await collection.updateOne(
			{ _id: "default" },
			{ $set: { callNumber } },
			{ upsert: true },
		);

		return callNumber;
	},
};

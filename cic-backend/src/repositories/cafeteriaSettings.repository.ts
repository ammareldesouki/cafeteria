import mongoose from "mongoose";

const collection = mongoose.connection.collection("cafeteria_no");

type CafeteriaSettingsDocument = {
  _id: string;
  callNumber: string;
};

export const cafeteriaSettingsRepository = {
  async getCallNumber(): Promise<string | null> {
    const doc = (await collection.findOne({
      _id: "default",
    })) as CafeteriaSettingsDocument | null;

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


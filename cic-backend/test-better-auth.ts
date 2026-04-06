import { betterAuth } from "better-auth";
import { mongodbAdapter } from "better-auth/adapters/mongodb";
import { MongoClient } from "mongodb";

const client = new MongoClient("mongodb://localhost");
const db = client.db();

const auth = betterAuth({
	database: mongodbAdapter(db),
	advanced: {
		useCookieSessionStorage: false, // Does this exist?
		// Let's see what options are in advanced
	},
});

import { mongodbAdapter } from "better-auth/adapters/mongodb";
import { MongoClient } from "mongodb";
import { betterAuth } from "better-auth";
import { bearer } from "better-auth/plugins";
import { DATABASE_URL, BETTER_AUTH_URL, BETTER_AUTH_SECRET } from "@config/env";

const client = new MongoClient(DATABASE_URL);
const db = client.db();

export const auth = betterAuth({
	database: mongodbAdapter(db),
	baseURL: BETTER_AUTH_URL,
	basePath: "/api/v1/auth",
	secret: BETTER_AUTH_SECRET,
	trustedOrigins: ["http://localhost:3000"],
	appName: "default",

	/* email and password */
	emailAndPassword: {
		enabled: true,
	},

	/* additional fields for the user */
	user: {
		additionalFields: {
			role: {
				type: "string",
				defaultValue: "user",
			},
			phoneNumber: {
				type: "string",
				required: false,
			},
			gender: {
				type: "string",
				required: false,
			},
		},
	},

	/* plugins */
	plugins: [bearer()],
});

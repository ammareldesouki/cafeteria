import { mongodbAdapter } from "better-auth/adapters/mongodb";
import { MongoClient } from "mongodb";
import { betterAuth } from "better-auth";
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
    },
  },

  /* plugins */
  plugins: [],
});

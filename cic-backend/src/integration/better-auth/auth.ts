import { mongodbAdapter } from "better-auth/adapters/mongodb";
import { MongoClient } from "mongodb";
import { betterAuth } from "better-auth";
import { bearer } from "better-auth/plugins";
import {
	DATABASE_URL,
	BETTER_AUTH_URL,
	BETTER_AUTH_SECRET,
	SMTP_HOST,
	SMTP_PORT,
	SMTP_USER,
	SMTP_PASS,
	SMTP_FROM,
} from "@config/env";
import nodemailer from "nodemailer";

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
		// Local-dev friendly password reset:
		// Better Auth will generate a reset URL (with a token query param).
		// We log it so you can copy/paste the token in Flutter without needing paid email/SMS.
		sendResetPassword: async ({ user, url }: any) => {
			const canSendEmail =
				!!SMTP_HOST && !!SMTP_PORT && !!SMTP_USER && !!SMTP_PASS && !!SMTP_FROM;

			const token = (() => {
				try {
					const parsed = new URL(url);
					return parsed.searchParams.get("token");
				} catch {
					return null;
				}
			})();

			console.log(
				`🔐 PASSWORD_RESET_REQUEST for ${user?.email || user?.phoneNumber}\n🔗 URL: ${url}${
					token ? `\n🔢 RESET_CODE: ${token}` : ""
				}`,
			);

			if (canSendEmail && user?.email) {
				try {
					const transporter = nodemailer.createTransport({
						host: SMTP_HOST,
						port: SMTP_PORT,
						secure: SMTP_PORT === 465,
						auth: { user: SMTP_USER, pass: SMTP_PASS },
					});

					await transporter.sendMail({
						from: SMTP_FROM,
						to: user.email,
						subject: "Reset your password",
						text: `Reset your password using this code: ${token}\nOr click here: ${url}`,
						html: `<p>Reset your password using this code: <b>${token}</b></p><p>Or click this link:</p><p><a href="${url}">${url}</a></p>`,
					});

					console.log(`📧 Password reset email sent to ${user.email}`);
				} catch (err) {
					console.error("❌ Failed to send reset email", err);
				}
			} else if (!canSendEmail) {
				console.log(
					"💡 SMTP not configured. For free/local testing, copy the RESET_CODE above into your app.",
				);
			}
		},
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

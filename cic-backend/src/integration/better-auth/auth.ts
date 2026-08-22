import { mongodbAdapter } from "better-auth/adapters/mongodb";
import { MongoClient } from "mongodb";
import { betterAuth } from "better-auth";
import { bearer } from "better-auth/plugins";
import {
	DATABASE_URL,
	BETTER_AUTH_URL,
	BETTER_AUTH_SECRET,
	CORS_ORIGIN_LIST,
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
	trustedOrigins:
		CORS_ORIGIN_LIST.length > 0 ? CORS_ORIGIN_LIST : ["http://localhost:3000"],
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
					// The token is often in the path: /reset-password/<token>
					const parts = parsed.pathname.split('/');
					const pathToken = parts[parts.length - 1];
					return parsed.searchParams.get("token") || pathToken;
				} catch {
					return null;
				}
			})();

			// Generate a 6-digit numeric OTP for better mobile UI
			const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
			
			if (token && user?.email) {
				try {
					const { otpRepository } = await import("@/repositories/otp.repository");
					// Clean up old OTPs first
					await otpRepository.deleteByEmail(user.email, "password_reset");
					// Store mapping: OTP Code -> Better Auth Token
					await otpRepository.create({
						email: user.email,
						code: otpCode,
						token: token, // Store the original better-auth token
						type: "password_reset",
						expiresAt: new Date(Date.now() + 10 * 60 * 1000), // 10 minutes
						createdAt: new Date(),
					});
				} catch (err) {
					console.error("Failed to store OTP mapping", err);
				}
			}

			console.log(
				`🔐 PASSWORD_RESET_REQUEST for ${user?.email || user?.phoneNumber}\n🔗 URL: ${url}${
					token ? `\n🔢 RESET_CODE: ${token}` : ""
				}\n🔢 OTP_CODE: ${otpCode}`,
			);

			// Send email in the background — do NOT await so the API responds instantly
			if (canSendEmail && user?.email) {
				const transporter = nodemailer.createTransport({
					host: SMTP_HOST,
					port: SMTP_PORT,
					secure: SMTP_PORT === 465,
					auth: { user: SMTP_USER, pass: SMTP_PASS },
					pool: true,           // reuse SMTP connections
					connectionTimeout: 8_000,
					greetingTimeout: 8_000,
					socketTimeout: 10_000,
				});

				// Fire-and-forget: respond to client immediately, deliver email async
				transporter.sendMail({
					from: SMTP_FROM,
					to: user.email,
					subject: "Reset your password",
					text: `Reset your password using this code: ${otpCode}\nOr click here: ${url}`,
					html: `
						<div style="font-family: sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
							<h2 style="color: #333;">Password Reset</h2>
							<p>Use the following 6-digit code to reset your password:</p>
							<div style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #4F46E5; margin: 20px 0;">${otpCode}</div>
							<p style="color: #666; font-size: 14px;">This code will expire in 10 minutes.</p>
							<hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
							<p style="font-size: 12px; color: #999;">If you didn't request this, please ignore this email.</p>
						</div>
					`,
				}).then(() => {
					console.log(`📧 Password reset OTP email sent to ${user.email}`);
				}).catch((err: unknown) => {
					console.error("❌ Failed to send reset email", err);
				});
			} else if (!canSendEmail) {
				console.log(
					"💡 SMTP not configured. For free/local testing, copy the OTP_CODE above into your app.",
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

	account: {
		accountLinking: {
			enabled: true,
			trustedProviders: ["google"],
		},
	},

	socialProviders: {
		google: {
			clientId: process.env.GOOGLE_CLIENT_ID || "1058634289271-6gm6151g6h5gaep6osljdarhrfl4lbkl.apps.googleusercontent.com",
			clientSecret: process.env.GOOGLE_CLIENT_SECRET || "dummy",
		},
	},

	/* plugins */
	plugins: [bearer()],
});

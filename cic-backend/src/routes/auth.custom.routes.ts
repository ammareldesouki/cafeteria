import { Router, Request, Response } from "express";
import { otpRepository } from "@/repositories/otp.repository";
import { auth } from "@/integration/better-auth/auth";

const router = Router();

/**
 * Request password reset (OTP)
 * Calls better-auth forgot-password which triggers our custom sendResetPassword with OTP
 */
router.post("/auth/request-password-reset", async (req: Request, res: Response) => {
	const { email } = req.body;
	if (!email) {
		res.status(400).json({ error: "Email is required" });
		return;
	}

	try {
		// This will trigger the sendResetPassword callback in auth.ts
		await auth.api.requestPasswordReset({
			body: { email },
		});
		res.json({ success: true, message: "OTP sent if user exists" });
	} catch (err: any) {
		res.status(500).json({ error: err.message });
	}
});

/**
 * Verify OTP and Reset Password
 */
router.post("/auth/verify-otp-reset", async (req: Request, res: Response) => {
	const { email, code, newPassword } = req.body;

	if (!email || !code || !newPassword) {
		res.status(400).json({ error: "Email, code and newPassword are required" });
		return;
	}

	try {
		const otpRecord = await otpRepository.findValidOTP(email, code, "password_reset");

		if (!otpRecord || !otpRecord.token) {
			res.status(400).json({ error: "Invalid or expired OTP" });
			return;
		}

		// Use the stored better-auth token to actually reset the password
		await auth.api.resetPassword({
			body: {
				token: otpRecord.token,
				newPassword,
			},
		});

		// Clean up the OTP record
		await otpRepository.deleteByEmail(email, "password_reset");

		res.json({ success: true, message: "Password reset successful" });
	} catch (err: any) {
		res.status(500).json({ error: err.message });
	}
});

export default router;

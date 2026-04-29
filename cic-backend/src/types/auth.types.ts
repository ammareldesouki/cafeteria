export interface OTP {
	_id?: any;
	email: string;
	code: string;
	token?: string; // Original better-auth token
	expiresAt: Date;
	type: "password_reset" | "email_verification";
	createdAt: Date;
}

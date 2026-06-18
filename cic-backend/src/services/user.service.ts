/**
 * Service Layer - Business Logic
 * Auth-related user operations. Uses better-auth integration.
 */
import { IncomingHttpHeaders } from "http";
import { auth } from "@/integration/better-auth/auth";

export const userService = {
	async updateUserName(name: string, headers: IncomingHttpHeaders) {
		const context = {
			method: "POST" as const,
			body: { name },
			headers,
		};

		await auth.api.updateUser(context);
		return { name };
	},

	async updateUserPhone(phoneNumber: string, headers: IncomingHttpHeaders) {
		const context = {
			method: "POST" as const,
			body: { phoneNumber },
			headers,
		};

		await auth.api.updateUser(context);
		return { phoneNumber };
	},
};

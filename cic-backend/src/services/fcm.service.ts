/**
 * FCM Service — sends push notifications via Firebase Admin SDK.
 *
 * Setup:
 *   1. Go to Firebase Console → Project Settings → Service Accounts
 *   2. "Generate new private key" → download JSON
 *   3. Save as `cic-backend/firebase-service-account.json`
 *   4. Set `FIREBASE_SERVICE_ACCOUNT_PATH` in .env (defaults to that path)
 */
import admin from "firebase-admin";
import { existsSync } from "node:fs";
import { resolve } from "node:path";
import { FIREBASE_SERVICE_ACCOUNT_PATH } from "@config/env";

let initialized = false;

/**
 * Resolve the service-account credentials from the environment.
 * Prefers FIREBASE_SERVICE_ACCOUNT_BASE64 (a single base64 line — immune to the
 * newline/quote mangling that breaks raw multi-line JSON in env vars), then
 * falls back to FIREBASE_SERVICE_ACCOUNT_JSON.
 */
function loadServiceAccountFromEnv(): Record<string, unknown> | null {
	const b64 = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
	if (b64) {
		try {
			const decoded = Buffer.from(b64.trim(), "base64").toString("utf8");
			return JSON.parse(decoded);
		} catch (err) {
			console.warn("⚠️  Failed to parse FIREBASE_SERVICE_ACCOUNT_BASE64", err);
		}
	}

	const envJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
	if (envJson) {
		try {
			// Tolerate a value accidentally wrapped in surrounding quotes.
			const trimmed = envJson.trim().replace(/^['"]|['"]$/g, "");
			return JSON.parse(trimmed);
		} catch (err) {
			console.warn("⚠️  Failed to parse FIREBASE_SERVICE_ACCOUNT_JSON", err);
		}
	}

	return null;
}

function init() {
	if (initialized) return;

	const serviceAccountFromEnv = loadServiceAccountFromEnv();
	if (serviceAccountFromEnv) {
		admin.initializeApp({
			credential: admin.credential.cert(serviceAccountFromEnv as any),
		});
		initialized = true;
		console.log("🔥 Firebase Admin initialized (from env var)");
		return;
	}

	const path = resolve(process.cwd(), FIREBASE_SERVICE_ACCOUNT_PATH);
	if (!existsSync(path)) {
		console.warn(
			"⚠️  Firebase service account not found at",
			path,
			"— FCM disabled.",
		);
		return;
	}
	const serviceAccount = require(path);
	admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
	initialized = true;
	console.log("🔥 Firebase Admin initialized (from file)");
}

/**
 * Send a push notification to one or more FCM tokens.
 * Silently skips if Firebase is not configured.
 */
export async function sendPushNotification(
	tokens: string[],
	payload: { title: string; body: string; data?: Record<string, string> },
): Promise<void> {
	init();
	if (!initialized || tokens.length === 0) return;

	const message: admin.messaging.MulticastMessage = {
		tokens,
		notification: { title: payload.title, body: payload.body },
		data: payload.data,
	};

	try {
		const response = await admin.messaging().sendEachForMulticast(message);
		const failures = response.responses.filter((r) => !r.success).length;
		if (failures > 0) {
			console.warn(`FCM: ${failures}/${tokens.length} messages failed`);
		}
	} catch (err) {
		console.error("FCM send error:", err);
	}
}

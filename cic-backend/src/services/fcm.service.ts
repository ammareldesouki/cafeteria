/**
 * FCM Service — sends push notifications via Firebase Admin SDK.
 *
 * Setup:
 *   1. Go to Firebase Console → Project Settings → Service Accounts
 *   2. "Generate new private key" → download JSON
 *   3. Deploy: set FIREBASE_SERVICE_ACCOUNT_BASE64 (base64 of that JSON).
 *      Local dev: save the JSON as `cic-backend/firebase-service-account.json`.
 */
import { readFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";
import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";
import type { MulticastMessage } from "firebase-admin/lib/messaging/messaging-api";
import { FIREBASE_SERVICE_ACCOUNT_PATH } from "@config/env";
import {
	type NotifContent,
	type NotifLang,
	normalizeLang,
} from "@/utils/notificationMessages";

let initialized = false;

/**
 * Resolve the service-account credentials from the environment.
 * Prefers FIREBASE_SERVICE_ACCOUNT_BASE64 (a single base64 line — immune to the
 * newline/quote mangling that breaks raw multi-line JSON in env vars), then
 * falls back to FIREBASE_SERVICE_ACCOUNT_JSON.
 */
function loadServiceAccountFromEnv(): Record<string, unknown> | null {
	// Prefer raw JSON var (full content via --stdin), then base64, then legacy JSON.
	const raw = process.env.FIREBASE_SERVICE_ACCOUNT_RAW_JSON;
	if (raw) {
		try {
			return JSON.parse(raw);
		} catch (err) {
			console.warn("⚠️  Failed to parse FIREBASE_SERVICE_ACCOUNT_RAW_JSON", err);
		}
	}

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
	if (getApps().length > 0) {
		initialized = true;
		return;
	}

	let serviceAccount = loadServiceAccountFromEnv();

	if (!serviceAccount) {
		const path = resolve(process.cwd(), FIREBASE_SERVICE_ACCOUNT_PATH);
		if (!existsSync(path)) {
			console.warn(
				"⚠️  Firebase service account not found at",
				path,
				"— FCM disabled.",
			);
			return;
		}
		serviceAccount = JSON.parse(readFileSync(path, "utf8"));
	}

	initializeApp({ credential: cert(serviceAccount as any) });
	initialized = true;
	console.log(
		"🔥 Firebase Admin initialized for project:",
		(serviceAccount as any).project_id ?? "unknown",
	);
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

	const message: MulticastMessage = {
		tokens,
		notification: { title: payload.title, body: payload.body },
		data: payload.data,
		// Play the default notification sound (bell) on both platforms.
		apns: {
			payload: { aps: { sound: "default" } },
		},
		android: {
			priority: "high",
			notification: { sound: "default", channelId: "high_importance_channel" },
		},
	};

	try {
		const response = await getMessaging().sendEachForMulticast(message);
		for (let i = 0; i < response.responses.length; i++) {
			const r = response.responses[i];
			if (!r.success) {
				const code = (r.error as any)?.code ?? "unknown";
				const msg = (r.error as any)?.message ?? r.error?.toString();
				console.warn(`FCM: token ${i} failed — ${code}: ${msg}`);
			}
		}
	} catch (err) {
		console.error("FCM send error:", err);
	}
}

/**
 * Send a notification to a set of token docs, localizing the copy per device
 * language. Tokens are grouped by `lang` so each recipient gets text in their
 * own language.
 */
export async function sendLocalizedNotification(
	tokenDocs: { token: string; lang?: string }[],
	build: (lang: NotifLang) => NotifContent,
	data?: Record<string, string>,
): Promise<void> {
	const byLang = new Map<NotifLang, string[]>();
	for (const doc of tokenDocs) {
		const lang = normalizeLang(doc.lang);
		const list = byLang.get(lang) ?? [];
		list.push(doc.token);
		byLang.set(lang, list);
	}

	for (const [lang, tokens] of byLang) {
		const { title, body } = build(lang);
		await sendPushNotification(tokens, { title, body, data });
	}
}

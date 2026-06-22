/**
 * FCM Service — sends push notifications via Firebase Admin SDK (modular imports).
 *
 * firebase-admin is externalized from the tsup bundle so its native deps
 * (google-auth-library etc.) resolve correctly at runtime.
 */
import { readFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";
import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";
import { FIREBASE_SERVICE_ACCOUNT_PATH } from "@config/env";
import {
	type NotifContent,
	type NotifLang,
	normalizeLang,
} from "@/utils/notificationMessages";

let initialized = false;

function loadServiceAccount() {
	const raw = process.env.FIREBASE_SERVICE_ACCOUNT_RAW_JSON;
	if (raw) {
		try { return JSON.parse(raw); } catch { /* fall through */ }
	}
	const b64 = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
	if (b64) {
		try {
			return JSON.parse(Buffer.from(b64.trim(), "base64").toString("utf8"));
		} catch { /* fall through */ }
	}
	const envJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
	if (envJson) {
		try {
			return JSON.parse(envJson.trim().replace(/^['"]|['"]$/g, ""));
		} catch { /* fall through */ }
	}
	const path = resolve(process.cwd(), FIREBASE_SERVICE_ACCOUNT_PATH);
	if (existsSync(path)) {
		return JSON.parse(readFileSync(path, "utf8"));
	}
	return null;
}

function init() {
	if (initialized) return;
	if (getApps().length > 0) {
		initialized = true;
		return;
	}

	const serviceAccount = loadServiceAccount();
	if (!serviceAccount) {
		console.warn("⚠️  Firebase service account not found — FCM disabled.");
		return;
	}

	initializeApp({ credential: cert(serviceAccount as any) });
	initialized = true;
	console.log(
		"🔥 Firebase Admin initialized for project:",
		(serviceAccount as any).project_id ?? "unknown",
	);
}

export async function sendPushNotification(
	tokens: string[],
	payload: { title: string; body: string; data?: Record<string, string> },
): Promise<void> {
	init();
	if (!initialized || tokens.length === 0) return;

	try {
		const response = await getMessaging().sendEachForMulticast({
			tokens,
			notification: { title: payload.title, body: payload.body },
			data: payload.data,
			apns: { payload: { aps: { sound: "default" } } },
			android: {
				priority: "high",
				notification: { sound: "default", channelId: "high_importance_channel" },
			},
		});
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

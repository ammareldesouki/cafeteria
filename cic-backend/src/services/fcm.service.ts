/**
 * FCM Service — sends push notifications via FCM HTTP v1 API.
 *
 * Uses google-auth-library (externalized from tsup bundle) to get OAuth tokens.
 */
import { readFileSync, existsSync } from "node:fs";
import { resolve } from "node:path";
import { GoogleAuth } from "google-auth-library";
import { FIREBASE_SERVICE_ACCOUNT_PATH } from "@config/env";
import {
	type NotifContent,
	type NotifLang,
	normalizeLang,
} from "@/utils/notificationMessages";

let auth: GoogleAuth | null = null;
let projectId: string | null = null;

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
	if (auth) return;
	const sa = loadServiceAccount();
	if (!sa) {
		console.warn("⚠️  Firebase service account not found — FCM disabled.");
		return;
	}
	projectId = (sa as any).project_id;
	auth = new GoogleAuth({
		credentials: sa as any,
		scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
	});
	console.log("🔥 FCM ready for project:", projectId);
}

async function getAccessToken(): Promise<string | null> {
	if (!auth) return null;
	try {
		const client = await auth.getClient();
		const token = await client.getAccessToken();
		return token?.token ?? null;
	} catch (err) {
		console.error("FCM getAccessToken error:", err);
		return null;
	}
}

async function sendSingle(
	token: string,
	payload: { title: string; body: string; data?: Record<string, string> },
): Promise<void> {
	const accessToken = await getAccessToken();
	if (!accessToken) return;

	const body = JSON.stringify({
		message: {
			token,
			notification: { title: payload.title, body: payload.body },
			data: payload.data,
			android: {
				priority: "high",
				notification: { sound: "default", channelId: "high_importance_channel" },
			},
			apns: { payload: { aps: { sound: "default" } } },
		},
	});

	const res = await fetch(
		`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
		{
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				Authorization: `Bearer ${accessToken}`,
			},
			body,
		},
	);
	if (!res.ok) {
		const text = await res.text();
		throw new Error(`${res.status}: ${text}`);
	}
}

export async function sendPushNotification(
	tokens: string[],
	payload: { title: string; body: string; data?: Record<string, string> },
): Promise<void> {
	init();
	if (!auth || !projectId || tokens.length === 0) return;

	// Get access token once for all tokens
	const accessToken = await getAccessToken();
	if (!accessToken) {
		console.warn("FCM: no access token available");
		return;
	}

	const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

	for (let i = 0; i < tokens.length; i++) {
		try {
			const body = JSON.stringify({
				message: {
					token: tokens[i],
					notification: { title: payload.title, body: payload.body },
					data: payload.data,
					android: {
						priority: "high",
						notification: { sound: "default", channelId: "high_importance_channel" },
					},
					apns: { payload: { aps: { sound: "default" } } },
				},
			});
			const res = await fetch(fcmUrl, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Authorization: `Bearer ${accessToken}`,
				},
				body,
			});
			if (!res.ok) {
				const text = await res.text();
				console.warn(`FCM: token ${i} failed — ${res.status}: ${text}`);
			}
		} catch (err) {
			console.error(`FCM: token ${i} error:`, err);
		}
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

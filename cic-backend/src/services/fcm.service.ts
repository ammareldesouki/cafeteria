import { GoogleAuth } from "google-auth-library";
import type {
	NotifContent,
	NotifLang,
} from "@/utils/notificationMessages";
import { normalizeLang } from "@/utils/notificationMessages";
import { fcmRepository } from "@/repositories/fcm.repository";

const REAP_ERRORS = new Set([
	"messaging/registration-token-not-registered",
	"messaging/invalid-argument",
	"messaging/invalid-registration-token",
]);

let auth: GoogleAuth | null = null;
let projectId: string | null = null;

function init() {
	if (auth) return;

	const raw = process.env.FIREBASE_SERVICE_ACCOUNT_RAW_JSON;
	if (!raw) {
		console.warn("FIREBASE_SERVICE_ACCOUNT_RAW_JSON not set — FCM disabled.");
		return;
	}

	try {
		const sa = JSON.parse(raw);
		if (sa.private_key) {
			sa.private_key = sa.private_key.replace(/\\n/g, "\n");
		}
		projectId = sa.project_id;
		auth = new GoogleAuth({
			credentials: sa,
			scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
		});
		console.log("🔥 FCM ready for project:", projectId);
	} catch (err) {
		console.error("FCM init error:", err);
	}
}

async function getBearerToken(): Promise<string | null> {
	if (!auth) return null;
	try {
		const token = await auth.getAccessToken();
		if (!token) {
			console.warn("FCM: GoogleAuth.getAccessToken() returned null");
			return null;
		}
		return token;
	} catch (err) {
		console.error("FCM: failed to get access token:", err);
		return null;
	}
}

export async function sendPushNotification(
	tokens: string[],
	payload: { title: string; body: string; data?: Record<string, string> },
): Promise<void> {
	init();
	if (!auth || !projectId || tokens.length === 0) return;

	const bearer = await getBearerToken();
	if (!bearer) {
		console.warn("FCM: no bearer token — skipping send");
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
					Authorization: `Bearer ${bearer}`,
				},
				body,
			});

			if (!res.ok) {
				const text = await res.text();
				let code = "unknown";
				try {
					const parsed = JSON.parse(text);
					code =
						parsed.error?.details?.[0]?.errorCode ??
						parsed.error?.status ??
						"unknown";
				} catch {}

				console.warn(`FCM: token ${i} failed — ${res.status}: ${code}`);

				if (res.status === 401) {
					console.error(
						"FCM 401 UNAUTHENTICATED — the bearer token was rejected. Token prefix:",
						bearer.substring(0, 20) + "...",
					);
				}

				if (res.status === 400 || res.status === 404) {
					if (REAP_ERRORS.has(`messaging/${code.toLowerCase()}`)) {
						fcmRepository.unregisterToken(tokens[i]).catch((e) =>
							console.error("FCM: failed to remove dead token:", e),
						);
					}
				}
			}
		} catch (err) {
			console.error(`FCM: token ${i} network error:`, err);
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

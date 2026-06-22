/**
 * FCM Service — sends push notifications via Firebase Admin SDK.
 *
 * Uses GOOGLE_APPLICATION_CREDENTIALS (set via start script) for auth.
 */
import { applicationDefault, initializeApp, getApps } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";
import type {
	NotifContent,
	NotifLang,
} from "@/utils/notificationMessages";
import { normalizeLang } from "@/utils/notificationMessages";

let initialized = false;

function init() {
	if (initialized) return;
	if (getApps().length > 0) {
		initialized = true;
		return;
	}
	try {
		initializeApp({ credential: applicationDefault() });
		initialized = true;
		console.log("🔥 Firebase Admin initialized via ADC");
	} catch (err) {
		console.error("Firebase Admin init error:", err);
	}
}

export async function sendPushNotification(
	tokens: string[],
	payload: { title: string; body: string; data?: Record<string, string> },
): Promise<void> {
	init();
	if (tokens.length === 0) return;
	try {
		const messaging = getMessaging();
		const result = await messaging.sendEachForMulticast({
			tokens,
			notification: { title: payload.title, body: payload.body },
			data: payload.data,
			android: {
				priority: "high",
				notification: { sound: "default", channelId: "high_importance_channel" },
			},
			apns: { payload: { aps: { sound: "default" } } },
		});
		for (let i = 0; i < result.responses.length; i++) {
			const r = result.responses[i];
			if (!r.success) {
				console.warn(`FCM: token ${i} failed — ${r.error?.code}: ${r.error?.message}`);
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

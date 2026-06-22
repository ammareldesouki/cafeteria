import { cert, initializeApp, getApps } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";
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

let initialized = false;

function init() {
	if (initialized) return;

	const existing = getApps();
	if (existing.length > 0) {
		initialized = true;
		console.log(
			"🔥 Firebase Admin already initialized (existing apps:",
			existing.map((a) => a.name).join(", "),
			")",
		);
		return;
	}

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
		initializeApp({
			credential: cert(sa),
			projectId: sa.project_id,
		});
		initialized = true;
		console.log("🔥 Firebase Admin initialized for project:", sa.project_id);
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
				const code = r.error?.code ?? "unknown";
				const msg = r.error?.message ?? "";
				console.warn(`FCM: token ${i} failed — ${code}: ${msg}`);

				if (REAP_ERRORS.has(code)) {
					fcmRepository.unregisterToken(tokens[i]).catch((e) =>
						console.error("FCM: failed to remove dead token:", e),
					);
				}
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

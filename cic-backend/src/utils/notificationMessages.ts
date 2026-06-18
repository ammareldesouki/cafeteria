/**
 * Localized push-notification text (English / Arabic).
 *
 * The backend can't use the Flutter app's l10n, so notification copy lives here
 * and is selected by the recipient device's stored language (see fcm_tokens.lang).
 */

export type NotifLang = "en" | "ar";

export interface NotifContent {
	title: string;
	body: string;
}

export function normalizeLang(lang?: string | null): NotifLang {
	return lang === "ar" ? "ar" : "en";
}

/** New-order alert sent to cafeteria staff. */
export function newOrderNotification(
	lang: string | undefined,
	p: { who: string; count: number; total: number; scheduledTime?: string },
): NotifContent {
	if (normalizeLang(lang) === "ar") {
		const when = p.scheduledTime ? ` للساعة ${p.scheduledTime}` : "";
		return {
			title: "🛎️ طلب جديد",
			body: `${p.who} قام بعمل طلب${when} — ${p.count} صنف، ${p.total} ج.م.`,
		};
	}
	const when = p.scheduledTime ? ` for ${p.scheduledTime}` : "";
	return {
		title: "🛎️ New Order",
		body: `${p.who} placed an order${when} — ${p.count} item(s), ${p.total} EGP.`,
	};
}

/** Reminder sent to staff ~10 min before a scheduled order is due. */
export function scheduledReminderNotification(
	lang: string | undefined,
	p: { orderShort: string; time: string },
): NotifContent {
	if (normalizeLang(lang) === "ar") {
		return {
			title: "🕐 طلب مجدول قادم",
			body: `الطلب رقم #${p.orderShort} المجدول الساعة ${p.time} مستحق خلال ~10 دقائق.`,
		};
	}
	return {
		title: "🕐 Upcoming Scheduled Order",
		body: `Order #${p.orderShort} scheduled at ${p.time} is due in ~10 minutes.`,
	};
}

/**
 * Order-tracking notification sent to the customer when an order's status
 * changes. Returns null for statuses we don't notify on (e.g. pending).
 */
export function orderStatusNotification(
	status: string,
	lang: string | undefined,
	p: { orderShort: string },
): NotifContent | null {
	const L = normalizeLang(lang);
	const table: Record<string, Record<NotifLang, NotifContent>> = {
		processing: {
			en: {
				title: "✅ Order Confirmed",
				body: `Your order #${p.orderShort} has been confirmed and is being prepared.`,
			},
			ar: {
				title: "✅ تم تأكيد الطلب",
				body: `تم تأكيد طلبك رقم #${p.orderShort} ويتم تحضيره الآن.`,
			},
		},
		completed: {
			en: {
				title: "🍽️ Order Ready",
				body: `Your order #${p.orderShort} is prepared and on its way / ready for pickup.`,
			},
			ar: {
				title: "🍽️ الطلب جاهز",
				body: `طلبك رقم #${p.orderShort} تم تحضيره وهو في الطريق / جاهز للاستلام.`,
			},
		},
		delivered: {
			en: {
				title: "📦 Order Delivered",
				body: `Your order #${p.orderShort} has been delivered. Enjoy!`,
			},
			ar: {
				title: "📦 تم تسليم الطلب",
				body: `تم تسليم طلبك رقم #${p.orderShort}. بالهناء والشفاء!`,
			},
		},
		cancelled: {
			en: {
				title: "❌ Order Cancelled",
				body: `Your order #${p.orderShort} has been cancelled.`,
			},
			ar: {
				title: "❌ تم إلغاء الطلب",
				body: `تم إلغاء طلبك رقم #${p.orderShort}.`,
			},
		},
	};

	return table[status]?.[L] ?? null;
}

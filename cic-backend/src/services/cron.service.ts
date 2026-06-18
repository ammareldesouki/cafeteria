/**
 * Cron Service — runs scheduled tasks in the background.
 *
 * Currently handles:
 *   - Scheduled order notification: sends FCM push to staff 10 min before
 *     a scheduled order's `scheduledFor` time.
 */
import cron from "node-cron";
import mongoose from "mongoose";
import { fcmRepository } from "@/repositories/fcm.repository";
import { sendLocalizedNotification } from "@/services/fcm.service";
import { scheduledReminderNotification } from "@/utils/notificationMessages";

/** Set of order IDs we've already notified about (in-memory dedup). */
const notified = new Set<string>();

export function startCronJobs() {
	// Run every minute
	cron.schedule("* * * * *", async () => {
		try {
			await checkScheduledOrders();
		} catch (err) {
			console.error("Cron error:", err);
		}
	});

	console.log("⏰ Cron jobs started");
}

async function checkScheduledOrders() {
	const now = new Date();
	// Window: orders scheduled between now+9 and now+11 minutes
	const lower = new Date(now.getTime() + 9 * 60 * 1000);
	const upper = new Date(now.getTime() + 11 * 60 * 1000);

	const orders = mongoose.connection.collection("orders");
	const upcoming = await orders
		.find({
			scheduledFor: { $gte: lower, $lte: upper },
			status: "pending",
		})
		.toArray();

	if (upcoming.length === 0) return;

	const tokenDocs = await fcmRepository.getStaffTokenDocs();
	if (tokenDocs.length === 0) return;

	for (const order of upcoming) {
		const orderId = (order as any)._id?.toString() ?? "";
		if (notified.has(orderId)) continue;
		notified.add(orderId);

		const scheduledTime = new Date(
			(order as any).scheduledFor,
		).toLocaleTimeString("en-US", {
			hour: "2-digit",
			minute: "2-digit",
		});

		await sendLocalizedNotification(
			tokenDocs,
			(lang) =>
				scheduledReminderNotification(lang, {
					orderShort: orderId.slice(-6),
					time: scheduledTime,
				}),
			{ orderId, type: "scheduled_order_reminder" },
		);
	}
}

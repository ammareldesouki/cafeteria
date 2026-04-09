/**
 * Repository Layer - Analytics Data Access
 * MongoDB aggregation queries for dashboard analytics
 */
import mongoose from "mongoose";
import { OrderStatus, PaymentStatus } from "@/types/order.types";

const collection = mongoose.connection.collection("orders");

export const analyticsRepository = {
	/**
	 * Get count of active (pending) orders
	 */
	async getActiveOrdersCount(): Promise<number> {
		return collection.countDocuments({ status: OrderStatus.PENDING });
	},

	/**
	 * Get total count of all orders
	 */
	async getTotalOrdersCount(): Promise<number> {
		return collection.countDocuments({});
	},

	/**
	 * Get total revenue from paid orders
	 */
	async getTotalRevenue(): Promise<number> {
		const result = await collection
			.aggregate([
				{ $match: { status: { $ne: OrderStatus.CANCELLED } } },
				{ $group: { _id: null, total: { $sum: "$totalPrice" } } },
			])
			.toArray();

		return result.length > 0 ? result[0].total : 0;
	},

	/**
	 * Get pending revenue from unpaid orders
	 */
	async getPendingRevenue(): Promise<number> {
		const result = await collection
			.aggregate([
				{ $match: { paymentStatus: PaymentStatus.UNPAID, status: { $ne: OrderStatus.CANCELLED } } },
				{ $group: { _id: null, total: { $sum: "$totalPrice" } } },
			])
			.toArray();

		return result.length > 0 ? result[0].total : 0;
	},
};

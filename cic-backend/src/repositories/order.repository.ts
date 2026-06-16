/**
 * Repository Layer - Orders Data Access
 * Abstracts database operations for orders.
 * All MongoDB queries for orders live here. No business logic.
 */
import mongoose from "mongoose";
import { Order, OrderStatus, PaymentStatus } from "@/types/order.types";
import { OrderFilters } from "@/types/admin.types";
import { ObjectId } from "mongodb";

const collection = mongoose.connection.collection<Order>("orders");

// Helper to build MongoDB query from filters
function buildFilterQuery(filters: OrderFilters): any {
	const query: Record<string, unknown> = {};

	if (filters.userId) query.userId = filters.userId;
	if (filters.paymentStatus) query.paymentStatus = filters.paymentStatus;
	if (filters.status) query.status = filters.status;
	
	if (filters.search) {
		// Match if the term is contained (case-insensitive) in ANY of these
		// fields. Escape regex specials so user input is treated literally.
		const safe = filters.search.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
		const rx = { $regex: safe, $options: "i" };
		query.$or = [
			{ username: rx }, // stored lowercase in the order document
			{ userEmail: rx },
			{ userPhone: rx },
			{ deliveryLocation: rx },
			{ "items.menuItemName": rx },
		];
	}
	
	if (filters.dateRange) {
		const now = new Date();
		const start = new Date(now);
		start.setHours(0, 0, 0, 0);
		
		if (filters.dateRange === "today") {
			query.createdAt = { $gte: start };
		} else if (filters.dateRange === "week") {
			start.setDate(now.getDate() - 7);
			query.createdAt = { $gte: start };
		} else if (filters.dateRange === "month") {
			start.setMonth(now.getMonth() - 1);
			query.createdAt = { $gte: start };
		}
	}
	
	return query;
}

export const orderRepository = {
	/**
	 * Create a new order
	 */
	async create(order: Order): Promise<Order> {
		const result = await collection.insertOne(order as Order);
		return { ...order, _id: result.insertedId };
	},

	/**
	 * Find all orders for a user
	 */
	async findByUserId(userId: string): Promise<Order[]> {
		return collection.find({ userId }).sort({ createdAt: -1 }).toArray();
	},

	/**
	 * Find a single order by ID
	 */
	async findById(orderId: string): Promise<Order | null> {
		return collection.findOne({ _id: new ObjectId(orderId) });
	},

	/**
	 * Update order status with validation
	 */
	async updateStatus(
		orderId: string,
		status: OrderStatus,
	): Promise<Order | null> {
		const result = await collection.findOneAndUpdate(
			{ _id: new ObjectId(orderId) },
			{ $set: { status, updatedAt: new Date() } },
			{ returnDocument: "after" },
		);
		return result || null;
	},

	/**
	 * Update payment status
	 */
	async updatePaymentStatus(
		orderId: string,
		paymentStatus: PaymentStatus,
	): Promise<Order | null> {
		const result = await collection.findOneAndUpdate(
			{ _id: new ObjectId(orderId) },
			{ $set: { paymentStatus, updatedAt: new Date() } },
			{ returnDocument: "after" },
		);
		return result || null;
	},

	/**
	 * Find all orders with filters (admin only)
	 */
	async findAllWithFilters(filters: OrderFilters): Promise<Order[]> {
		const query = buildFilterQuery(filters);

		return collection.find(query).sort({ createdAt: -1 }).toArray();
	},

	/**
	 * Count orders with filters
	 */
	async countWithFilters(filters: OrderFilters): Promise<number> {
		const query = buildFilterQuery(filters);

		return collection.countDocuments(query);
	},

	/**
	 * Find orders with pagination and filters (admin only)
	 */
	async findAllPaginated(
		page: number,
		limit: number,
		filters: OrderFilters,
	): Promise<Order[]> {
		const query = buildFilterQuery(filters);

		const skip = (page - 1) * limit;

		return collection
			.find(query)
			.sort({ createdAt: -1 })
			.skip(skip)
			.limit(limit)
			.toArray();
	},

	/**
	 * Find orders by status (for admin operations)
	 */
	async findByStatus(status: OrderStatus): Promise<Order[]> {
		return collection.find({ status }).sort({ createdAt: -1 }).toArray();
	},

	/**
	 * Delivered-but-unpaid orders grouped by user: how many each user owes for.
	 * Returns the latest known username per user.
	 */
	async deliveredUnpaidByUser(): Promise<
		{ userId: string; username?: string; count: number }[]
	> {
		const rows = await collection
			.aggregate([
				{
					$match: {
						status: OrderStatus.DELIVERED,
						paymentStatus: PaymentStatus.UNPAID,
					},
				},
				{ $sort: { createdAt: -1 } },
				{
					$group: {
						_id: "$userId",
						username: { $first: "$username" },
						count: { $sum: 1 },
					},
				},
			])
			.toArray();
		return rows.map((r) => ({
			userId: r._id as string,
			username: r.username as string | undefined,
			count: r.count as number,
		}));
	},

	/**
	 * Mark all of a user's delivered-but-unpaid orders as paid. Updates only the
	 * payment status (the wallet is settled separately by the caller, so this
	 * must NOT trigger wallet settlement to avoid double-crediting).
	 */
	async markUserDeliveredOrdersPaid(userId: string): Promise<number> {
		const result = await collection.updateMany(
			{
				userId,
				status: OrderStatus.DELIVERED,
				paymentStatus: PaymentStatus.UNPAID,
			},
			{ $set: { paymentStatus: PaymentStatus.PAID, updatedAt: new Date() } },
		);
		return result.modifiedCount;
	},
};

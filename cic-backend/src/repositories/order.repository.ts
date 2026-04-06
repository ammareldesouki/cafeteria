/**
 * Repository Layer - Orders Data Access
 * Abstracts database operations for orders.
 * All MongoDB queries for orders live here. No business logic.
 */
import mongoose from "mongoose";
import { Order, OrderStatus, PaymentStatus } from "@/types/order.types";
import { ObjectId } from "mongodb";

const collection = mongoose.connection.collection<Order>("orders");

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
	async findAllWithFilters(filters: {
		userId?: string;
		paymentStatus?: PaymentStatus;
		status?: OrderStatus;
	}): Promise<Order[]> {
		const query: Record<string, unknown> = {};

		if (filters.userId) query.userId = filters.userId;
		if (filters.paymentStatus) query.paymentStatus = filters.paymentStatus;
		if (filters.status) query.status = filters.status;

		return collection.find(query).sort({ createdAt: -1 }).toArray();
	},

	/**
	 * Count orders with filters
	 */
	async countWithFilters(filters: {
		userId?: string;
		paymentStatus?: PaymentStatus;
		status?: OrderStatus;
	}): Promise<number> {
		const query: Record<string, unknown> = {};

		if (filters.userId) query.userId = filters.userId;
		if (filters.paymentStatus) query.paymentStatus = filters.paymentStatus;
		if (filters.status) query.status = filters.status;

		return collection.countDocuments(query);
	},

	/**
	 * Find orders with pagination and filters (admin only)
	 */
	async findAllPaginated(
		page: number,
		limit: number,
		filters: {
			userId?: string;
			paymentStatus?: PaymentStatus;
			status?: OrderStatus;
		},
	): Promise<Order[]> {
		const query: Record<string, unknown> = {};

		if (filters.userId) query.userId = filters.userId;
		if (filters.paymentStatus) query.paymentStatus = filters.paymentStatus;
		if (filters.status) query.status = filters.status;

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
};

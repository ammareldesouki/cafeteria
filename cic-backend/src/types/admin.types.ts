/**
 * Type definitions for Admin Dashboard
 */
import { OrderStatus, PaymentStatus } from "./order.types";

export interface DashboardAnalytics {
	activeOrders: number;
	totalOrders: number;
	totalRevenue: number;
	pendingRevenue: number;
}

export interface OrderFilters {
	userId?: string;
	search?: string;
	dateRange?: string;
	paymentStatus?: PaymentStatus;
	status?: OrderStatus;
	page?: number;
	limit?: number;
}

/**
 * Service Layer - Analytics Business Logic
 * Aggregates dashboard analytics data
 */
import { analyticsRepository } from "@/repositories/analytics.repository";
import { DashboardAnalytics } from "@/types/admin.types";

export const analyticsService = {
	/**
	 * Get all dashboard analytics
	 */
	async getDashboardAnalytics(): Promise<DashboardAnalytics> {
		// Run queries in parallel for performance
		const [activeOrders, totalOrders, totalRevenue, pendingRevenue] =
			await Promise.all([
				analyticsRepository.getActiveOrdersCount(),
				analyticsRepository.getTotalOrdersCount(),
				analyticsRepository.getTotalRevenue(),
				analyticsRepository.getPendingRevenue(),
			]);

		return {
			activeOrders,
			totalOrders,
			totalRevenue,
			pendingRevenue,
		};
	},
};

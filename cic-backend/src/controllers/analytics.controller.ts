/**
 * Controller Layer - Analytics HTTP Handler
 * Admin dashboard analytics endpoints
 */
import { Request, Response, NextFunction } from "express";
import { analyticsService } from "@/services/analytics.service";

/**
 * Get dashboard analytics
 * GET /admin/analytics
 */
export const getDashboardAnalytics = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const analytics = await analyticsService.getDashboardAnalytics();
    res.json(analytics);
  } catch (err) {
    next(err);
  }
};

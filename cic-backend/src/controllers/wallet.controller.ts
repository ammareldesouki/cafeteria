/**
 * Controller Layer - Wallet HTTP Handler
 * Parse HTTP input → Call service → Return HTTP response
 */
import { Request, Response, NextFunction } from "express";
import { walletService } from "@/services/wallet.service";

/**
 * Get wallet balance
 * GET /admin/wallet
 */
export const getWalletBalance = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    // Call service
    const wallet = await walletService.getWalletBalance();

    // Return response
    res.json({
      balance: wallet.balance,
      updatedAt: wallet.updatedAt,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * Get wallet details with transactions
 * GET /admin/wallet/details?page=1&limit=10
 */
export const getWalletDetails = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    // Parse input (validated and parsed by middleware)
    const { page, limit } = (req as any).pagination;

    // Call service
    const details = await walletService.getWalletDetails(page, limit);

    // Return response
    res.json(details);
  } catch (err) {
    next(err);
  }
};

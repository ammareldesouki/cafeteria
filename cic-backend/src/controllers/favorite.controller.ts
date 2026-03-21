/**
 * Controller Layer - Favorites HTTP Handler
 * Parse HTTP input → Call service → Return HTTP response
 */
import { Request, Response, NextFunction } from "express";
import { favoriteService } from "@/services/favorite.service";
import { handleServiceError } from "@/middlewares/serviceErrorHandler.middleware";

/**
 * Add a favorite
 * POST /favorites
 */
export const addFavorite = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    // Parse input
    const userId = (req as any).user.id;
    const { itemId } = req.body;

    // Call service
    const favorite = await favoriteService.addFavorite(userId, itemId);

    // Return response
    res.status(201).json(favorite);
  } catch (err) {
    try {
      handleServiceError(err, res);
    } catch (unhandledErr) {
      next(unhandledErr);
    }
  }
};

/**
 * Get all favorites for user
 * GET /favorites
 */
export const getFavorites = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    // Parse input
    const userId = (req as any).user.id;

    // Call service
    const favorites = await favoriteService.getUserFavorites(userId);

    // Return response
    res.json(favorites);
  } catch (err) {
    next(err);
  }
};

/**
 * Remove a favorite
 * DELETE /favorites/:itemId
 */
export const removeFavorite = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    // Parse input
    const userId = (req as any).user.id;
    const itemId = req.params.itemId as string;

    // Call service
    const result = await favoriteService.removeFavorite(userId, itemId);

    // Return response
    res.json(result);
  } catch (err) {
    try {
      handleServiceError(err, res);
    } catch (unhandledErr) {
      next(unhandledErr);
    }
  }
};

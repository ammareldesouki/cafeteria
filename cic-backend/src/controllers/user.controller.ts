/**
 * Controller Layer - User HTTP Handler
 * Parse HTTP input → Call service → Return HTTP response
 */
import { Request, Response, NextFunction } from "express";
import { userService } from "@/services/user.service";
import { handleServiceError } from "@/middlewares/serviceErrorHandler.middleware";

/**
 * Update user name
 * PATCH /user/name
 */
export const updateName = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    // Parse input
    const { name } = req.body;

    // Call service
    const result = await userService.updateUserName(name, req.headers);

    // Return response
    res.json({ success: true, name: result.name });
  } catch (err) {
    try {
      handleServiceError(err, res);
    } catch (unhandledErr) {
      next(unhandledErr);
    }
  }
};

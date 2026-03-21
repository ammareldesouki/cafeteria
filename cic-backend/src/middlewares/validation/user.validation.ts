/**
 * Validation Middleware - User Input Validation
 */
import { Request, Response, NextFunction } from "express";

/**
 * Validate user name update
 */
export const validateUpdateName = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const { name } = req.body;

  if (!name || typeof name !== "string") {
    return res.status(400).json({ message: "Invalid name" });
  }

  if (name.length < 3 || name.length > 20) {
    return res.status(400).json({ message: "Name must be 3–20 chars" });
  }

  if (!/^[a-zA-Z0-9_]+$/.test(name)) {
    return res
      .status(400)
      .json({ message: "Name can contain letters, numbers, _ only" });
  }

  next();
};

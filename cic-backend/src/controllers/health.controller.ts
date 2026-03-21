/**
 * Controller Layer - HTTP Handler
 * Health check endpoint. No service layer needed (stateless).
 */
import { Request, Response } from "express";

export const healthCheck = (_req: Request, res: Response) => {
  res.json({
    status: "ok",
    uptime: Math.floor(process.uptime()),
    timestamp: Date.now(),
    isoTime: new Date().toISOString(),
  });
};

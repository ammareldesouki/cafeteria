import { Request, Response, NextFunction } from "express";
import { auth } from "@/integration/better-auth/auth";
import { fromNodeHeaders } from "better-auth/node";

export async function requireAuthNameMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const session = await auth.api.getSession({
    headers: fromNodeHeaders(req.headers),
  });

  if (!session?.user) {
    return res.status(401).json({ message: "Unauthorized" });
  }

  /* inject the user into the request */
  (req as any).user = session.user;

  next();
}

import { Request, Response, NextFunction } from "express";

export function authNameFromEmailMiddleware(
  req: Request,
  _res: Response,
  next: NextFunction
) {
  /* if the email is provided and the name is not provided, set the name to the email */
  if (req.body?.email && !req.body?.name) {
    req.body.name = req.body.email.split("@")[0];
  }

  next();
}

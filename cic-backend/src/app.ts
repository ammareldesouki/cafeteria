import express from "express";
import cors from "cors";
import rateLimit from "express-rate-limit";
import morgan from "morgan";

import {
	NODE_ENV,
	LOG_FORMAT,
	CREDENTIALS,
	CORS_ORIGIN_LIST,
} from "@config/env";

import router from "@/routes";
import { ErrorMiddleware } from "@middlewares/error.middleware";
import { NotFoundMiddleware } from "@middlewares/notFound.middleware";
import { stream } from "@utils/logger";

const app = express();
const env = NODE_ENV || "development";
const apiPrefix = "/api/v1";

/* trust proxy */
app.set("trust proxy", 1);

/* middlewares */
app.use(
	rateLimit({
		windowMs: 60_000,
		limit: env === "production" ? 100 : 1000,
		standardHeaders: true,
		legacyHeaders: false,
	}),
);

app.use(morgan(LOG_FORMAT || "dev", { stream }));

const allowedOrigins =
	CORS_ORIGIN_LIST.length > 0 ? CORS_ORIGIN_LIST : ["http://localhost:3000"];

app.use(
	cors({
		origin: (origin, cb) => {
			if (!origin || allowedOrigins.includes(origin)) cb(null, true);
			else cb(new Error("Not allowed by CORS"));
		},
		credentials: CREDENTIALS,
	}),
);

app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

/* routes - all under /api/v1 */
app.use(apiPrefix, router);

/* errors */
app.use(NotFoundMiddleware);
app.use(ErrorMiddleware);

export default app;

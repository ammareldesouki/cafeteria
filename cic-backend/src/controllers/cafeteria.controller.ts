import { Request, Response, NextFunction } from "express";
import { cafeteriaSettingsService } from "@/services/cafeteriaSettings.service";

export const getCafeteriaCallNumber = async (
	_req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const result = await cafeteriaSettingsService.getCallNumber();
		res.json(result);
	} catch (err) {
		next(err);
	}
};

export const updateCafeteriaCallNumber = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const { callNumber } = req.body as { callNumber: string };
		const result = await cafeteriaSettingsService.updateCallNumber(callNumber);
		res.json(result);
	} catch (err) {
		next(err);
	}
};

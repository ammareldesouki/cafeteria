/**
 * Wallet atomicity helper.
 *
 * Runs balance-update + ledger-write inside a single MongoDB transaction so the
 * cached balance can never diverge from the ledger. Atlas / replica-set
 * deployments support transactions; for a single-node mongod (e.g. a local
 * `mongodb://localhost` dev box) transactions are unavailable, so we transparently
 * fall back to running the work without a session.
 */
import mongoose, { type ClientSession } from "mongoose";

let transactionsUnsupported = false;

/**
 * Execute `work` atomically. `work` receives a session (or null when running in
 * fallback mode) and must pass it through to every collection operation it makes.
 */
export async function runWalletTransaction<T>(
	work: (session: ClientSession | null) => Promise<T>,
): Promise<T> {
	if (transactionsUnsupported) {
		return work(null);
	}

	const session = await mongoose.connection.startSession();
	try {
		let result!: T;
		await session.withTransaction(async () => {
			result = await work(session);
		});
		return result;
	} catch (err: unknown) {
		// IllegalOperation (20) / "Transaction numbers are only allowed on a replica set"
		const e = err as { code?: number; message?: string };
		const message = String(e?.message ?? "");
		if (
			e?.code === 20 ||
			message.includes("Transaction numbers are only allowed") ||
			message.includes("replica set") ||
			message.includes("Transactions are not supported")
		) {
			transactionsUnsupported = true;
			return work(null);
		}
		throw err;
	} finally {
		await session.endSession();
	}
}

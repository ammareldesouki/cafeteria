# Wallet System - How It Works

## Overview

There are **two wallets**, both using a cached-balance + append-only ledger pattern:

1. **Per-user wallet** (`user_wallets`) — a **debt ledger**. A user's balance goes
   **negative** when an order is delivered but not paid (they owe the cafeteria),
   and returns toward 0 when that debt is settled.
2. **Cafeteria wallet** (`cafeteria_wallets`, singleton) — **realized cash revenue
   only**. It is credited when an order is actually paid and debited if a paid
   order's revenue is later reversed.

Money does **not** move when an order is created. All wallet movement happens when
staff change an order on delivery / payment.

---

## Collections

| Collection | Purpose | Cardinality |
|---|---|---|
| `user_wallets` | `{ userId, balance, updatedAt }` — per-user balance (negative = owes) | one per user |
| `user_wallet_transactions` | `{ userId, orderId, amount, type, description, createdAt }` | many |
| `cafeteria_wallets` | `{ balance, updatedAt }` — realized revenue | 1 (singleton) |
| `cafeteria_wallet_transactions` | realized-revenue ledger | many |

---

## Lifecycle & settlement

Settlement is computed as the **delta** between the order's state before and after
an admin update (`order.service.ts → settleWallets`). Two signed effects define
each state:

- **User effect:** `−total` while `status = delivered AND paymentStatus = unpaid`, else `0`.
- **Cafeteria effect:** `+total` while `paymentStatus = paid AND status ≠ cancelled`, else `0`.

The delta between before/after is applied as a credit/debit. This makes every
transition correct and idempotent, and makes cancellation automatically net out
whatever was previously applied.

| Event | User wallet | Cafeteria wallet |
|---|---|---|
| Place order (pending / unpaid) | no change | no change |
| → `delivered` while `unpaid` | DEBIT −total (now owes) | no change (stays pending) |
| `unpaid → paid` (at delivery or later) | CREDIT +total (debt cleared) | CREDIT +total (revenue realized) |
| `paid → unpaid` (reversal) | DEBIT −total | DEBIT −total |
| Cancel | reverse only what was applied | reverse only what was applied |

### Paying off a debt later
An order delivered unpaid stays as `delivered + unpaid`, keeping it in pending
revenue and the user's balance negative. When the customer pays the cash later,
staff open **that same order** and set `paymentStatus = paid`. That single change
credits the user (debt → 0), credits the cafeteria (revenue realized), and drops
the order out of pending revenue.

---

## Atomicity

Each balance update + ledger write runs inside one MongoDB transaction
(`utils/walletTransaction.ts → runWalletTransaction`), so the cached balance can
never diverge from the ledger. On a single-node mongod (no transaction support)
it transparently falls back to sequential writes.

---

## Analytics (derived, not stored)

- **Total revenue** = sum of `paid`, non-cancelled orders.
- **Pending revenue** = sum of `delivered + unpaid` orders
  (equivalently the total debt across user wallets,
  `userWalletRepository.sumNegativeBalances()`).

---

## API Endpoints

### User (own wallet)
```
GET /api/v1/me/wallet            → { balance, updatedAt }      (negative = owes)
GET /api/v1/me/wallet/details    → { balance, updatedAt, transactions: {...} }
```

### Admin (cafeteria wallet)
```
GET /api/v1/admin/wallet                    → { balance, updatedAt }
GET /api/v1/admin/wallet/details?page&limit → { balance, updatedAt, transactions: {...} }
```

---

## Example

```
1. Customer creates order #123 (total 30)   user: 0     cafeteria: 0
2. Staff: status → delivered, still unpaid   user: -30   cafeteria: 0   (pending +30)
3. Customer pays cash later → paymentStatus = paid
                                             user: 0     cafeteria: +30 (pending -30)
```

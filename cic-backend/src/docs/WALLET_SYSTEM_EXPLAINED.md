# Wallet System - How It Works

## Overview

The wallet system automatically tracks all order payments using a **cached balance** + **transaction ledger** pattern for optimal performance.

---

## Architecture

### Two Collections

#### 1. `cafeteria_wallets` (Cache - Fast Reads)

**Purpose:** Store current balance for instant queries  
**Updates:** Every time payment status changes  
**Documents:** 1 (singleton)

```json
{
  "_id": ObjectId,
  "balance": 2500.00,  // Can be negative (credit owed)
  "updatedAt": ISODate
}
```

#### 2. `cafeteria_wallet_transactions` (Ledger - Audit Trail)

**Purpose:** Complete audit trail of all financial transactions  
**Updates:** Append-only (never delete)  
**Documents:** Many (one per transaction)

```json
{
  "_id": ObjectId,
  "orderId": "order123",
  "amount": 29.99,
  "type": "credit",  // or "debit"
  "description": "Payment received for order order123",
  "createdAt": ISODate
}
```

---

## Automatic Wallet Updates

### Trigger: Admin Updates Order

When admin calls `PATCH /api/v1/admin/orders/:id`, the wallet is **automatically updated** based on payment status changes.

### Scenarios

#### Scenario 1: Unpaid → Paid (Payment Received)

```
Original: paymentStatus = "unpaid"
Update:   paymentStatus = "paid"

Action:
1. ✅ Create CREDIT transaction in ledger
2. ✅ Add amount to wallet balance
3. ✅ Update wallet.updatedAt

Result:
- Wallet balance increases by order.total
- Transaction type: "credit"
- Description: "Payment received for order {orderId}"
```

#### Scenario 2: Delivered Unpaid (Pay Later / Credit)

```
Original: status = "pending", paymentStatus = "unpaid"
Update:   status = "completed", paymentStatus = "unpaid"

Action:
1. ✅ Create DEBIT transaction in ledger
2. ✅ Subtract amount from wallet balance (can go negative)
3. ✅ Update wallet.updatedAt

Result:
- Wallet balance decreases by order.total
- Balance can be negative = money owed to cafeteria
- Transaction type: "debit"
- Description: "Order {orderId} delivered unpaid (credit)"
```

#### Scenario 3: Delivered & Paid Simultaneously

```
Update: status = "completed", paymentStatus = "paid"

Action:
1. ✅ Create CREDIT transaction in ledger
2. ✅ Add amount to wallet balance
3. ✅ Update wallet.updatedAt

Result:
- Wallet balance increases by order.total
- Transaction type: "credit"
```

#### Scenario 4: Paid → Unpaid (Reversal - Rare)

```
Original: paymentStatus = "paid"
Update:   paymentStatus = "unpaid"

Action:
1. ✅ Create DEBIT transaction in ledger
2. ✅ Subtract amount from wallet balance
3. ✅ Update wallet.updatedAt

Result:
- Wallet balance decreases by order.total
- Used for payment reversals/refunds
```

---

## Balance Interpretation

### Positive Balance

```
balance: 2500.00
```

**Meaning:** Cafeteria has $2,500 in the wallet (money received from paid orders)

### Zero Balance

```
balance: 0.00
```

**Meaning:** All money received has been withdrawn or no orders yet

### Negative Balance (Credit System)

```
balance: -350.00
```

**Meaning:** Customers owe $350 to cafeteria (orders delivered but not paid)

---

## Performance Optimization

### Why Two Collections?

#### Fast Reads (cafeteria_wallets)

```
// Super fast - single document lookup
GET /api/v1/admin/wallet

db.cafeteria_wallets.findOne({})
// Returns instantly: { balance: 2500.00 }
```

#### Detailed Audit (cafeteria_wallet_transactions)

```
// When you need the full history
GET /api/v1/admin/wallet/details?page=1&limit=50

db.cafeteria_wallet_transactions
  .find({})
  .sort({ createdAt: -1 })
  .skip(0)
  .limit(50)
```

### Analytics Performance

**Old Way (SLOW):**

```javascript
// Aggregate all unpaid orders every time
db.orders.aggregate([
  { $match: { paymentStatus: "unpaid" } },
  { $group: { _id: null, total: { $sum: "$total" } } },
]);
// Scans entire orders collection 😰
```

**New Way (FAST):**

```javascript
// Read cached balance
const wallet = await walletService.getWalletBalance();
const pendingRevenue = wallet.balance < 0 ? Math.abs(wallet.balance) : 0;
// Single document read! ⚡
```

---

## Transaction Types

### CREDIT (Money In)

- Payment received
- Increases wallet balance

```json
{
  "type": "credit",
  "amount": 29.99,
  "description": "Payment received for order abc123"
}
```

### DEBIT (Money Out/Owed)

- Order delivered unpaid
- Payment reversal
- Decreases wallet balance

```json
{
  "type": "debit",
  "amount": 45.5,
  "description": "Order xyz789 delivered unpaid (credit)"
}
```

---

## Code Flow

### When Admin Updates Order

```typescript
// admin.controller.ts
PATCH /api/v1/admin/orders/:id
↓
// order.service.ts - updateOrderByAdmin()
1. Get original order state
2. Update order status/paymentStatus
3. Detect changes
4. IF paymentStatus changed:
   → Call walletService.recordPayment() or recordDelivery()
5. Return updated order
↓
// wallet.service.ts
1. Update wallet balance (increment/decrement)
2. Create transaction record
3. Both operations succeed or fail together
```

### Wallet Service Methods

```typescript
// Credit wallet (payment received)
walletService.recordPayment(orderId, amount)
→ wallet.balance += amount
→ transaction: { type: "credit", amount }

// Debit wallet (order delivered unpaid)
walletService.recordDelivery(orderId, amount)
→ wallet.balance -= amount
→ transaction: { type: "debit", amount }
```

---

## Example Workflow

### Timeline

```
1. Customer creates order #123
   Order: { total: 29.99, status: "pending", paymentStatus: "unpaid" }
   Wallet: unchanged

2. Admin marks delivered unpaid (pay later)
   PATCH /admin/orders/123 { status: "completed" }

   → Creates DEBIT transaction:
     { orderId: "123", amount: 29.99, type: "debit" }
   → Wallet balance: 0.00 - 29.99 = -29.99
   → Wallet status: Customer owes $29.99

3. Customer pays later
   PATCH /admin/orders/123 { paymentStatus: "paid" }

   → Creates CREDIT transaction:
     { orderId: "123", amount: 29.99, type: "credit" }
   → Wallet balance: -29.99 + 29.99 = 0.00
   → Wallet status: Balanced

4. Another customer pays immediately
   PATCH /admin/orders/456 { status: "completed", paymentStatus: "paid" }

   → Creates CREDIT transaction:
     { orderId: "456", amount: 45.50, type: "credit" }
   → Wallet balance: 0.00 + 45.50 = 45.50
   → Wallet status: $45.50 in wallet
```

---

## API Endpoints

### Get Balance (Fast)

```bash
GET /api/v1/admin/wallet

Response:
{
  "balance": 2500.00,
  "updatedAt": "2024-01-13T12:00:00Z"
}
```

### Get Full History (Detailed)

```bash
GET /api/v1/admin/wallet/details?page=1&limit=50

Response:
{
  "balance": 2500.00,
  "updatedAt": "2024-01-13T12:00:00Z",
  "transactions": {
    "data": [...50 transactions...],
    "totalCount": 1234,
    "page": 1,
    "limit": 50,
    "totalPages": 25
  }
}
```

---

## Key Benefits

### ✅ Automatic

- No manual wallet updates needed
- Updates happen when admin changes order status
- Always in sync with order data

### ✅ Performant

- Wallet balance is cached (single document read)
- Dashboard analytics use cached balance
- Transaction history paginated

### ✅ Auditable

- Complete transaction history
- Never delete transactions (append-only)
- Full audit trail for accounting

### ✅ Flexible

- Supports credit system (negative balance)
- Handles payment reversals
- Handles "pay later" scenarios

---

## Testing

### Test Wallet Updates

```bash
# 1. Create an order (as user)
POST /api/v1/orders
{ itemIds: [...], total: 29.99, ... }

# 2. Check wallet (should be 0.00 if new)
GET /api/v1/admin/wallet
→ { balance: 0.00 }

# 3. Mark order as delivered unpaid
PATCH /api/v1/admin/orders/ORDER_ID
{ status: "completed" }

# 4. Check wallet (should be negative)
GET /api/v1/admin/wallet
→ { balance: -29.99 }

# 5. Check transactions
GET /api/v1/admin/wallet/details
→ {
  balance: -29.99,
  transactions: {
    data: [{
      type: "debit",
      amount: 29.99,
      description: "Order ... delivered unpaid (credit)"
    }]
  }
}

# 6. Mark as paid
PATCH /api/v1/admin/orders/ORDER_ID
{ paymentStatus: "paid" }

# 7. Check wallet (should be 0.00)
GET /api/v1/admin/wallet
→ { balance: 0.00 }

# 8. Check transactions (should have 2 entries)
GET /api/v1/admin/wallet/details
→ 2 transactions: 1 debit, 1 credit
```

---

## Summary

✅ **Wallet updates automatically** when admin changes order payment status  
✅ **Balance is cached** for fast reads  
✅ **Transactions are logged** for audit trail  
✅ **Supports credit system** (negative balance = money owed)  
✅ **Used by analytics** for pending revenue calculation

No manual intervention needed - just update orders, wallet handles the rest! 🎉


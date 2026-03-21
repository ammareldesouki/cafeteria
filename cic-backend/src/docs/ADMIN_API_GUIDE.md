# Admin Dashboard API Guide

## Overview

Admin-only endpoints for dashboard analytics, order management, and wallet operations.

---

## Authentication

All admin endpoints require:

1. **Valid session** (better-auth cookie)
2. **Admin role** (`role: "admin"` in user document)

### Setting Admin Role

Manually update a user in MongoDB:

```javascript
db.user.updateOne({ email: "admin@example.com" }, { $set: { role: "admin" } });
```

### Authorization Errors

- `401 Unauthorized` - Not logged in or invalid session
- `403 Admin access required` - Logged in but not admin

---

## Endpoints

### 1. Dashboard Analytics

#### `GET /api/v1/admin/analytics`

Get dashboard summary statistics.

**Response:**

```json
{
  "activeOrders": 5,
  "totalOrders": 150,
  "totalRevenue": 4500.0,
  "pendingRevenue": 350.0
}
```

**Fields:**

- `activeOrders` - Count of orders with status "pending"
- `totalOrders` - Total count of all orders
- `totalRevenue` - Sum of all paid orders
- `pendingRevenue` - Sum of all unpaid orders

---

### 2. Order Management

#### `GET /api/v1/admin/orders`

Get all orders with pagination and optional filters.

**Query Parameters:**

- `page` (optional) - Page number, default: 1
- `limit` (optional) - Items per page (1-1000), default: 10
- `userId` (optional) - Filter by specific user
- `paymentStatus` (optional) - Filter: `paid` | `unpaid`
- `status` (optional) - Filter: `pending` | `completed` | `cancelled`

**Examples:**

```
# Get all orders (page 1, limit 10)
GET /api/v1/admin/orders

# Get orders with custom pagination
GET /api/v1/admin/orders?page=2&limit=100

# Get orders for specific user
GET /api/v1/admin/orders?userId=abc123

# Get all unpaid orders
GET /api/v1/admin/orders?paymentStatus=unpaid

# Get pending orders
GET /api/v1/admin/orders?status=pending

# Combined filters
GET /api/v1/admin/orders?userId=abc123&paymentStatus=unpaid&status=pending&limit=50
```

**Response:**

```json
{
  "data": [
    {
      "_id": "order1",
      "userId": "user123",
      "userEmail": "user@example.com",
      "itemIds": ["item1", "item2"],
      "total": 29.99,
      "deliveryLocation": "123 Main St",
      "status": "pending",
      "paymentStatus": "unpaid",
      "createdAt": "2024-01-13T12:00:00Z",
      "updatedAt": "2024-01-13T12:00:00Z"
    }
  ],
  "totalCount": 150,
  "page": 1,
  "limit": 10,
  "totalPages": 15
}
```

---

#### `PATCH /api/v1/admin/orders/:id`

Update order status and/or payment status (admin can update any order).

**Body Parameters:**

- `status` (optional) - `pending` | `completed` | `cancelled`
- `paymentStatus` (optional) - `paid` | `unpaid`

At least one field must be provided.

**Examples:**

**1. Mark as delivered and paid:**

```json
PATCH /api/v1/admin/orders/ORDER_ID

{
  "status": "completed",
  "paymentStatus": "paid"
}
```

**2. Mark as delivered but unpaid (credit):**

```json
{
  "status": "completed",
  "paymentStatus": "unpaid"
}
```

**3. Customer paid for previously unpaid order:**

```json
{
  "paymentStatus": "paid"
}
```

**4. Cancel order:**

```json
{
  "status": "cancelled"
}
```

**Response:**

```json
{
  "_id": "order1",
  "userId": "user123",
  "status": "completed",
  "paymentStatus": "paid",
  "updatedAt": "2024-01-13T12:30:00Z",
  ...all other fields
}
```

---

### 3. Wallet Management

#### `GET /api/v1/admin/wallet`

Get cafeteria wallet balance (fast query).

**Response:**

```json
{
  "balance": 2500.0,
  "updatedAt": "2024-01-13T12:00:00Z"
}
```

**Balance can be negative** - indicates money owed to cafeteria (credit).

---

#### `GET /api/v1/admin/wallet/details`

Get wallet balance with transaction history (paginated).

**Query Parameters:**

- `page` (optional) - Page number, default: 1
- `limit` (optional) - Transactions per page (1-1000), default: 10

**Examples:**

```
GET /api/v1/admin/wallet/details
GET /api/v1/admin/wallet/details?page=2&limit=50
```

**Response:**

```json
{
  "balance": 2500.0,
  "updatedAt": "2024-01-13T12:00:00Z",
  "transactions": {
    "data": [
      {
        "_id": "txn1",
        "orderId": "order123",
        "amount": 29.99,
        "type": "credit",
        "description": "Payment received for order order123",
        "createdAt": "2024-01-13T12:00:00Z"
      },
      {
        "_id": "txn2",
        "orderId": "order124",
        "amount": 45.5,
        "type": "debit",
        "description": "Order order124 delivered unpaid (credit)",
        "createdAt": "2024-01-13T11:00:00Z"
      }
    ],
    "totalCount": 500,
    "page": 1,
    "limit": 10,
    "totalPages": 50
  }
}
```

**Transaction Types:**

- `credit` - Money received (increases balance)
- `debit` - Money owed (decreases balance, can go negative)

---

## Wallet & Order Workflow

### Scenario 1: Order Delivered & Paid Immediately

```
1. Customer creates order → status: "pending", paymentStatus: "unpaid"
2. Admin marks delivered & paid → PATCH /admin/orders/:id
   {
     "status": "completed",
     "paymentStatus": "paid"
   }
3. Result: Wallet balance increases by order total
```

### Scenario 2: Order Delivered, Pay Later (Credit)

```
1. Customer creates order → status: "pending", paymentStatus: "unpaid"
2. Admin marks delivered but unpaid → PATCH /admin/orders/:id
   {
     "status": "completed",
     "paymentStatus": "unpaid"
   }
3. Result: Wallet balance decreases (can go negative = credit owed)
4. Later, customer pays → PATCH /admin/orders/:id
   {
     "paymentStatus": "paid"
   }
5. Result: Wallet balance increases by order total
```

---

## Pagination Best Practices

### Performance

- Use `limit=10` for UI pagination (default)
- Use `limit=100` for bulk operations
- Use `limit=1000` for exports (max allowed)

### Example Pagination UI

```javascript
// Get page 1
const response = await fetch("/api/v1/admin/orders?page=1&limit=10");
const { data, totalPages, page } = await response.json();

// Show "Next" button if page < totalPages
// Show "Previous" button if page > 1
```

---

## Filter Combinations

### Common Use Cases

**1. Find specific user's unpaid orders:**

```
GET /api/v1/admin/orders?userId=USER_ID&paymentStatus=unpaid
```

**2. Find all active pending orders:**

```
GET /api/v1/admin/orders?status=pending&limit=100
```

**3. Find all completed but unpaid orders (credit owed):**

```
GET /api/v1/admin/orders?status=completed&paymentStatus=unpaid
```

**4. Export all orders:**

```
GET /api/v1/admin/orders?limit=1000
```

---

## Error Handling

### 400 Bad Request

```json
{
  "message": "Invalid pagination. Page >= 1, Limit 1-1000"
}
```

### 401 Unauthorized

```json
{
  "message": "Unauthorized"
}
```

### 403 Forbidden

```json
{
  "message": "Admin access required"
}
```

### 404 Not Found

```json
{
  "message": "Order not found"
}
```

---

## Postman Collection

Import `postman_admin_collection.json` for all admin endpoints.

### Setup:

1. Import collection
2. Login as admin user in browser
3. Get session cookie from DevTools
4. In Postman → Cookies → Add for `localhost`:
   ```
   better-auth.session_token=YOUR_ADMIN_TOKEN
   ```

**Important:** User must have `role: "admin"` in database.

---

## MongoDB Collections

### cafeteria_wallets

Single document storing current balance:

```json
{
  "_id": ObjectId,
  "balance": 2500.00,
  "updatedAt": ISODate
}
```

### cafeteria_wallet_transactions

Append-only ledger:

```json
{
  "_id": ObjectId,
  "orderId": "order123",
  "amount": 29.99,
  "type": "credit",
  "description": "Payment received...",
  "createdAt": ISODate
}
```

---

## Quick Reference

| Endpoint                | Method | Purpose                |
| ----------------------- | ------ | ---------------------- |
| `/admin/analytics`      | GET    | Dashboard stats        |
| `/admin/orders`         | GET    | List/filter orders     |
| `/admin/orders/:id`     | PATCH  | Update order           |
| `/admin/wallet`         | GET    | Balance only           |
| `/admin/wallet/details` | GET    | Balance + transactions |

All endpoints require admin role! 🔒


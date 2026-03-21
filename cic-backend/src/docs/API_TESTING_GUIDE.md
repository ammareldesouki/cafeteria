# API Testing Guide

## Quick Test with cURL/Thunder Client

### Prerequisites

1. Server running on `http://localhost:3001`
2. Must be authenticated (have valid better-auth session)

---

## Favorites Endpoints

### 1. Add a Favorite

```bash
POST http://localhost:3001/favorites
Content-Type: application/json
Cookie: better-auth.session_token=YOUR_SESSION_TOKEN

{
  "itemId": "VALID_MENU_ITEM_ID"
}
```

**Expected Response (201):**

```json
{
  "_id": "...",
  "userId": "user123",
  "itemId": "VALID_MENU_ITEM_ID",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### 2. Get All Favorites

```bash
GET http://localhost:3001/favorites
Cookie: better-auth.session_token=YOUR_SESSION_TOKEN
```

**Expected Response (200):**

```json
[
  {
    "_id": "...",
    "userId": "user123",
    "itemId": "item1",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
]
```

### 3. Remove a Favorite

```bash
DELETE http://localhost:3001/favorites/ITEM_ID
Cookie: better-auth.session_token=YOUR_SESSION_TOKEN
```

**Expected Response (200):**

```json
{
  "success": true
}
```

---

## Orders Endpoints

### 1. Create an Order

```bash
POST http://localhost:3001/orders
Content-Type: application/json
Cookie: better-auth.session_token=YOUR_SESSION_TOKEN

{
  "itemIds": ["MENU_ITEM_ID_1", "MENU_ITEM_ID_2"],
  "total": 29.99,
  "deliveryLocation": "123 Main St, Apt 4B"
}
```

**Expected Response (201):**

```json
{
  "_id": "...",
  "userId": "user123",
  "userEmail": "user@example.com",
  "itemIds": ["item1", "item2"],
  "total": 29.99,
  "deliveryLocation": "123 Main St, Apt 4B",
  "status": "pending",
  "paymentStatus": "unpaid",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### 2. Get All Orders

```bash
GET http://localhost:3001/orders
Cookie: better-auth.session_token=YOUR_SESSION_TOKEN
```

**Expected Response (200):**

```json
[
  {
    "_id": "...",
    "userId": "user123",
    "status": "pending",
    ...
  }
]
```

### 3. Get Single Order

```bash
GET http://localhost:3001/orders/ORDER_ID
Cookie: better-auth.session_token=YOUR_SESSION_TOKEN
```

### 4. Update Order Status

```bash
PATCH http://localhost:3001/orders/ORDER_ID/status
Content-Type: application/json
Cookie: better-auth.session_token=YOUR_SESSION_TOKEN

{
  "status": "completed"
}
```

**Valid Status Values:**

- `pending`
- `completed`
- `cancelled`

### 5. Update Payment Status

```bash
PATCH http://localhost:3001/orders/ORDER_ID/payment
Content-Type: application/json
Cookie: better-auth.session_token=YOUR_SESSION_TOKEN

{
  "paymentStatus": "paid"
}
```

**Valid Payment Status Values:**

- `paid`
- `unpaid`

---

## Error Responses

### 401 Unauthorized

```json
{
  "message": "Unauthorized"
}
```

### 400 Bad Request

```json
{
  "message": "Invalid itemId"
}
```

### 404 Not Found

```json
{
  "message": "Menu item not found"
}
```

### 403 Forbidden

```json
{
  "message": "Unauthorized"
}
```

### 409 Conflict

```json
{
  "message": "Item already favorited"
}
```

---

## Getting Menu Item IDs

First, get available menu items:

```bash
GET http://localhost:3001/menu
```

Then use the `_id` field from any item for testing favorites/orders.

---

## Testing Flow

1. **Start Server**: `npm run dev:watch`
2. **Login** via better-auth to get session token
3. **Get Menu Items** to find valid item IDs
4. **Test Favorites**:
   - Add favorite with valid item ID
   - Get favorites list
   - Remove favorite
5. **Test Orders**:
   - Create order with valid item IDs
   - Get all orders
   - Get specific order
   - Update order status
   - Update payment status

---

## Tips

- Use Thunder Client, Postman, or REST Client VS Code extension
- Save the session token in environment variables
- Test error cases (invalid IDs, duplicate favorites, etc.)
- Verify authorization (try accessing other users' orders)


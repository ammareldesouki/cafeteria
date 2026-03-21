# Postman Collection Setup Guide

## 📥 Import the Collection

1. Open Postman
2. Click **Import** button (top left)
3. Select the file: `postman_collection.json`
4. Click **Import**

---

## 🔧 Setup Environment Variables

After importing, you need to configure the collection variables:

### 1. Set BASE_URL (if different from localhost:3001)

- Click on the collection name
- Go to **Variables** tab
- Update `BASE_URL` if needed (default: `http://localhost:3001`)

### 2. Get Your Session Token

**Option A: From Browser DevTools**

1. Login to your app in the browser
2. Open DevTools (F12)
3. Go to **Application** tab → **Cookies**
4. Find `better-auth.session_token`
5. Copy the value

**Option B: From Network Tab**

1. Login to your app
2. Open DevTools → **Network** tab
3. Look at any authenticated request
4. Check the **Cookie** header
5. Copy the `better-auth.session_token` value

### 3. Add Cookie to Postman (IMPORTANT!)

**Use Postman's Cookies Tab (Recommended Method):**

1. In Postman, click the **Cookies** link (below the Send button)
2. Type `localhost` in the domain field
3. Click **Add Cookie**
4. Paste this (replace with your actual token):
   ```
   better-auth.session_token=YOUR_ACTUAL_TOKEN_VALUE; Path=/; HttpOnly; Expires=Fri, 28 Feb 2026 19:35:23 GMT;
   ```
5. Click **Save**

**IMPORTANT:**

- ❌ **DO NOT** add a `Cookie` header in the Headers tab
- ✅ **ONLY** use the Cookies tab
- ❌ **DO NOT** add an Authorization header
- Postman will automatically send cookies from the Cookies tab

### 4. Remove Headers (If Any)

1. Run the **Helper Endpoints → Get Menu Items** request
2. Copy an `_id` from the response
3. Update `MENU_ITEM_ID` variable with this ID
4. Click **Save**

---

## 🧪 Testing Flow

### Step 1: Verify Server is Running

Run: **Helper Endpoints → Health Check**

- Should return `200 OK`

### Step 2: Get Menu Items

Run: **Helper Endpoints → Get Menu Items**

- Copy some `_id` values for testing

### Step 3: Test Favorites

1. **Add Favorite** - Add a menu item to favorites
2. **Get All Favorites** - Verify it was added
3. **Remove Favorite** - Remove it from favorites

### Step 4: Test Orders

1. **Create Order** - Create a new order with valid item IDs
2. **Get All Orders** - See your orders list
3. **Get Order by ID** - View specific order (update `ORDER_ID` variable)
4. **Update Order Status** - Change to "completed"
5. **Update Payment Status** - Mark as "paid"

---

## 📝 Request Examples

### Adding a Favorite

```json
POST /favorites
{
  "itemId": "65a1b2c3d4e5f6g7h8i9j0k1"
}
```

### Creating an Order

```json
POST /orders
{
  "itemIds": ["65a1b2c3d4e5f6g7h8i9j0k1", "65a1b2c3d4e5f6g7h8i9j0k2"],
  "total": 29.99,
  "deliveryLocation": "123 Main St, Apt 4B"
}
```

### Updating Order Status

```json
PATCH /orders/:id/status
{
  "status": "completed"
}

Valid values: "pending", "completed", "cancelled"
```

### Updating Payment Status

```json
PATCH /orders/:id/payment
{
  "paymentStatus": "paid"
}

Valid values: "paid", "unpaid"
```

---

## ✅ Expected Status Codes

| Status | Meaning      | When                                                |
| ------ | ------------ | --------------------------------------------------- |
| 200    | OK           | Successful GET, PATCH, DELETE                       |
| 201    | Created      | Successful POST (create)                            |
| 400    | Bad Request  | Invalid input data                                  |
| 401    | Unauthorized | Missing or invalid session token                    |
| 403    | Forbidden    | Not authorized (e.g., accessing other user's order) |
| 404    | Not Found    | Resource doesn't exist                              |
| 409    | Conflict     | Duplicate (e.g., item already favorited)            |

---

## 🐛 Troubleshooting

### Getting 401 Unauthorized?

- ✅ Make sure your `SESSION_TOKEN` is set correctly
- ✅ Check if the token is still valid (not expired)
- ✅ Re-login and get a fresh token

### Getting 404 Not Found?

- ✅ Verify the `MENU_ITEM_ID` or `ORDER_ID` exists
- ✅ Run "Get Menu Items" to find valid IDs
- ✅ Make sure MongoDB has menu items in the `menu_items` collection

### Getting 400 Bad Request?

- ✅ Check your request body format
- ✅ Ensure required fields are present
- ✅ Validate enum values (status, paymentStatus)

---

## 🎯 Quick Tips

1. **Save Responses**: Click "Save Response" to create example responses
2. **Use Variables**: The `{{MENU_ITEM_ID}}` and `{{ORDER_ID}}` variables are used throughout
3. **Test Scripts**: You can add test scripts to auto-extract IDs from responses
4. **Environments**: Consider creating separate environments for dev/staging/prod

---

## 📋 Collection Structure

```
CIC Backend - Favorites & Orders API
│
├── Favorites (3 requests)
│   ├── Add Favorite
│   ├── Get All Favorites
│   └── Remove Favorite
│
├── Orders (5 requests)
│   ├── Create Order
│   ├── Get All Orders
│   ├── Get Order by ID
│   ├── Update Order Status
│   └── Update Payment Status
│
└── Helper Endpoints (2 requests)
    ├── Get Menu Items
    └── Health Check
```

---

## 🔄 Auto-Update Variables (Advanced)

Add this test script to **Create Order** request to auto-save the order ID:

```javascript
// Tests tab
pm.test("Status is 201", function () {
  pm.response.to.have.status(201);
});

// Save the order ID for later use
if (pm.response.code === 201) {
  var response = pm.response.json();
  pm.collectionVariables.set("ORDER_ID", response._id);
}
```

This will automatically update the `ORDER_ID` variable after creating an order!

---

Happy Testing! 🚀


# Quick Reference: Controller Refactoring

## What Changed

### Files Created ✨
```
src/middlewares/
├── validation/
│   ├── index.ts                          ← Export all validations
│   ├── order.validation.ts               ← Order input validation
│   ├── user.validation.ts                ← User input validation
│   ├── favorite.validation.ts            ← Favorite input validation
│   └── wallet.validation.ts              ← Wallet input validation
└── serviceErrorHandler.middleware.ts     ← Service error → HTTP status
```

### Files Modified 🔄
```
src/controllers/
├── order.controller.ts                   ← Removed validation
├── admin.controller.ts                   ← Removed validation & filters parsing
├── user.controller.ts                    ← Removed validation
├── favorite.controller.ts                ← Removed validation
└── wallet.controller.ts                  ← Removed validation

src/routes/
├── order.routes.ts                       ← Added validation middleware
├── admin.routes.ts                       ← Added validation middleware
├── user.routes.ts                        ← Added validation middleware
├── favorite.routes.ts                    ← Added validation middleware
└── wallet.routes.ts                      ← Added validation middleware

src/services/
└── analytics.service.ts                  ← Fixed revenue calculation
```

## Controller Pattern

### Every controller now follows this exact pattern:

```typescript
export const controllerName = async (req, res, next) => {
  try {
    // 1️⃣ Parse HTTP input
    const { field1, field2 } = req.body;
    const userId = (req as any).user.id;

    // 2️⃣ Call service
    const result = await service.method(field1, field2);

    // 3️⃣ Return HTTP response
    res.status(200).json(result);
  } catch (err) {
    try {
      handleServiceError(err, res);
    } catch (unhandledErr) {
      next(unhandledErr);
    }
  }
};
```

## Request Flow

```
┌──────────────────────────────────────────────┐
│  Client sends HTTP request                   │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  Route matches endpoint                      │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  Auth Middleware (requireAuth/requireAdmin)  │
│  ├─ Validates JWT token                      │
│  └─ Attaches user to req                     │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  Validation Middleware ⭐ NEW                │
│  ├─ Validates request data                   │
│  ├─ Checks types & formats                   │
│  ├─ Validates enums                          │
│  ├─ Returns 400 if invalid                   │
│  └─ Attaches parsed data to req              │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  Controller ⭐ CLEAN                         │
│  ├─ Parse input from req                     │
│  ├─ Call service method                      │
│  └─ Return HTTP response                     │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  Service Error Handler ⭐ NEW                │
│  ├─ Maps service errors to HTTP codes        │
│  ├─ Known errors → specific status           │
│  └─ Unknown errors → global handler          │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  Response sent to client                     │
└──────────────────────────────────────────────┘
```

## Example Endpoint Comparison

### BEFORE ❌
```typescript
// order.routes.ts
router.post("/orders", requireAuth, createOrder);

// order.controller.ts
export const createOrder = async (req, res, next) => {
  try {
    const { itemIds, total, deliveryLocation } = req.body;

    // ❌ Validation in controller
    if (!itemIds || !Array.isArray(itemIds) || itemIds.length === 0) {
      return res.status(400).json({ message: "Invalid itemIds" });
    }

    if (typeof total !== "number" || total <= 0) {
      return res.status(400).json({ message: "Invalid total" });
    }

    if (!deliveryLocation || typeof deliveryLocation !== "string") {
      return res.status(400).json({ message: "Invalid deliveryLocation" });
    }

    const order = await orderService.createOrder(...);
    res.status(201).json(order);

  } catch (err: any) {
    // ❌ Error handling in controller
    if (err.message === "One or more menu items not found") {
      return res.status(404).json({ message: err.message });
    }
    next(err);
  }
};
```

### AFTER ✅
```typescript
// order.routes.ts
router.post("/orders", requireAuth, validateCreateOrder, createOrder);
                                    ^^^^^^^^^^^^^^^^^^ 
                                    Validation middleware

// order.validation.ts
export const validateCreateOrder = (req, res, next) => {
  const { itemIds, total, deliveryLocation } = req.body;

  if (!itemIds || !Array.isArray(itemIds) || itemIds.length === 0) {
    return res.status(400).json({ message: "Invalid itemIds" });
  }

  if (typeof total !== "number" || total <= 0) {
    return res.status(400).json({ message: "Invalid total" });
  }

  if (!deliveryLocation || typeof deliveryLocation !== "string") {
    return res.status(400).json({ message: "Invalid deliveryLocation" });
  }

  next(); // ✅ Validation passed
};

// order.controller.ts
export const createOrder = async (req, res, next) => {
  try {
    // 1. Parse input
    const userId = (req as any).user.id;
    const userEmail = (req as any).user.email;
    const { itemIds, total, deliveryLocation } = req.body;

    // 2. Call service
    const order = await orderService.createOrder(
      userId, userEmail, itemIds, total, deliveryLocation
    );

    // 3. Return response
    res.status(201).json(order);
  } catch (err) {
    try {
      handleServiceError(err, res); // ✅ Centralized error handling
    } catch (unhandledErr) {
      next(unhandledErr);
    }
  }
};
```

## Validation Middleware Available

```typescript
// Order validation
import {
  validateCreateOrder,
  validateOrderStatus,
  validatePaymentStatus,
  validateAdminOrderUpdate,
  validatePagination,
  validateOrderFilters,
} from "@/middlewares/validation";

// User validation
import { validateUpdateName } from "@/middlewares/validation";

// Favorite validation
import { validateItemIdBody, validateItemIdParam } from "@/middlewares/validation";

// Wallet validation
import { validateWalletPagination } from "@/middlewares/validation";
```

## Error Status Mapping

The `handleServiceError` middleware automatically maps these errors:

| Service Error Message              | HTTP Status | Response          |
|------------------------------------|-------------|-------------------|
| "Order not found"                  | 404         | Not Found         |
| "Menu item not found"              | 404         | Not Found         |
| "One or more menu items not found" | 404         | Not Found         |
| "Favorite not found"               | 404         | Not Found         |
| "Unauthorized"                     | 403         | Forbidden         |
| "Item already favorited"           | 409         | Conflict          |
| "Name already taken"               | 409         | Conflict          |
| Other errors                       | 500         | Internal Error    |

## Key Benefits

1. ✅ **Controllers are clean** - Only HTTP concerns
2. ✅ **Validation is reusable** - DRY principle
3. ✅ **Easy to test** - Each layer independently
4. ✅ **Consistent pattern** - All endpoints work the same
5. ✅ **Better maintainability** - Clear separation of concerns

## Documentation

- `CONTROLLER_ARCHITECTURE.md` - Full architecture guide
- `REFACTORING_SUMMARY.md` - Complete change summary
- `QUICK_REFERENCE.md` - This file

---

**Remember:** Controllers should ONLY: Parse → Call → Return


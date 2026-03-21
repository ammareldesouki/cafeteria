# Controller Layer Refactoring - Architecture Documentation

## Overview
This document explains the refactored controller architecture following proper separation of concerns and layered architecture principles.

## Architecture Principles

### Controllers Should ONLY:
1. **Parse HTTP Input** - Extract data from req.body, req.params, req.query, req.headers
2. **Call Service** - Delegate business logic to service layer
3. **Return HTTP Response** - Send res.json() or appropriate HTTP response

### Controllers Should NOT:
- ❌ Contain validation logic (moved to middleware)
- ❌ Contain business logic (belongs in services)
- ❌ Access database directly (use repositories via services)
- ❌ Have complex error handling logic (use centralized error handler)

## Architecture Layers

```
┌─────────────────────────────────────────┐
│         HTTP Request (Client)           │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Routes (Routing Layer)          │
│  - Define endpoints                     │
│  - Attach middleware chain              │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      Validation Middleware              │
│  - Validate input format                │
│  - Validate enums/types                 │
│  - Parse and normalize data             │
│  - Return 400 errors for bad input      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│          Controllers                    │
│  - Parse HTTP input                     │
│  - Call service methods                 │
│  - Return HTTP response                 │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      Service Error Handler              │
│  - Map service errors to HTTP codes     │
│  - Known errors → specific status       │
│  - Unknown errors → next(err)           │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│           Services                      │
│  - Business logic                       │
│  - Orchestrate repositories             │
│  - Throw meaningful errors              │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Repositories                    │
│  - Database access                      │
│  - Data queries                         │
│  - CRUD operations                      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│           Database                      │
└─────────────────────────────────────────┘
```

## File Structure

```
src/
├── middlewares/
│   ├── validation/
│   │   ├── index.ts                    # Export all validations
│   │   ├── order.validation.ts         # Order input validation
│   │   ├── user.validation.ts          # User input validation
│   │   ├── favorite.validation.ts      # Favorite input validation
│   │   └── wallet.validation.ts        # Wallet input validation
│   └── serviceErrorHandler.middleware.ts  # Service error → HTTP status mapper
│
├── routes/
│   ├── order.routes.ts                # Attach validation middleware
│   ├── admin.routes.ts                # Attach validation middleware
│   ├── user.routes.ts                 # Attach validation middleware
│   ├── favorite.routes.ts             # Attach validation middleware
│   └── wallet.routes.ts               # Attach validation middleware
│
├── controllers/
│   ├── order.controller.ts            # Clean HTTP handlers
│   ├── admin.controller.ts            # Clean HTTP handlers
│   ├── user.controller.ts             # Clean HTTP handlers
│   ├── favorite.controller.ts         # Clean HTTP handlers
│   └── wallet.controller.ts           # Clean HTTP handlers
│
└── services/
    ├── order.service.ts               # Business logic
    ├── user.service.ts                # Business logic
    ├── favorite.service.ts            # Business logic
    └── wallet.service.ts              # Business logic
```

## Validation Middleware

### Location
`src/middlewares/validation/`

### Responsibilities
- Validate request input (body, params, query)
- Check data types, formats, and constraints
- Validate enums (OrderStatus, PaymentStatus, etc.)
- Parse and normalize data (e.g., pagination)
- Attach parsed/validated data to `req` object
- Return 400 errors with descriptive messages

### Example
```typescript
export const validateCreateOrder = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const { itemIds, total, deliveryLocation } = req.body;

  if (!itemIds || !Array.isArray(itemIds) || itemIds.length === 0) {
    return res.status(400).json({ message: "Invalid itemIds array" });
  }

  if (typeof total !== "number" || total <= 0) {
    return res.status(400).json({ message: "Invalid total" });
  }

  if (!deliveryLocation || typeof deliveryLocation !== "string") {
    return res.status(400).json({ message: "Invalid deliveryLocation" });
  }

  next(); // Validation passed, continue to controller
};
```

## Service Error Handler Middleware

### Location
`src/middlewares/serviceErrorHandler.middleware.ts`

### Responsibilities
- Map service-level errors to HTTP status codes
- Handle known errors (404, 403, 409, etc.)
- Pass unknown errors to global error handler
- Remove error handling logic from controllers

### Error Mapping
```typescript
const ERROR_STATUS_MAP: Record<string, number> = {
  "Order not found": 404,
  "Menu item not found": 404,
  "Unauthorized": 403,
  "Item already favorited": 409,
  "Name already taken": 409,
};
```

### Usage in Controllers
```typescript
export const createOrder = async (req, res, next) => {
  try {
    // Parse input
    const userId = (req as any).user.id;
    const { itemIds, total, deliveryLocation } = req.body;

    // Call service
    const order = await orderService.createOrder(userId, userEmail, itemIds, total, deliveryLocation);

    // Return response
    res.status(201).json(order);
  } catch (err) {
    try {
      handleServiceError(err, res);
    } catch (unhandledErr) {
      next(unhandledErr); // Pass to global error handler
    }
  }
};
```

## Controller Pattern (Before vs After)

### ❌ BEFORE - Validation in Controller
```typescript
export const createOrder = async (req, res, next) => {
  try {
    const { itemIds, total, deliveryLocation } = req.body;

    // 🔴 Validation logic in controller
    if (!itemIds || !Array.isArray(itemIds) || itemIds.length === 0) {
      return res.status(400).json({ message: "Invalid itemIds array" });
    }

    if (typeof total !== "number" || total <= 0) {
      return res.status(400).json({ message: "Invalid total" });
    }

    // 🔴 Error handling in controller
    const order = await orderService.createOrder(...);
    res.status(201).json(order);
  } catch (err: any) {
    if (err.message === "One or more menu items not found") {
      return res.status(404).json({ message: err.message });
    }
    next(err);
  }
};
```

### ✅ AFTER - Clean Controller
```typescript
export const createOrder = async (req, res, next) => {
  try {
    // Parse input
    const userId = (req as any).user.id;
    const { itemIds, total, deliveryLocation } = req.body;

    // Call service
    const order = await orderService.createOrder(userId, userEmail, itemIds, total, deliveryLocation);

    // Return response
    res.status(201).json(order);
  } catch (err) {
    try {
      handleServiceError(err, res);
    } catch (unhandledErr) {
      next(unhandledErr);
    }
  }
};
```

## Routes Pattern

### Example: Order Routes
```typescript
import { Router } from "express";
import { requireAuth } from "@/middlewares/auth/requireAuth.middleware";
import { validateCreateOrder, validateOrderStatus } from "@/middlewares/validation";
import { createOrder, updateOrderStatus } from "@/controllers/order.controller";

const router = Router();

// Middleware chain: Auth → Validation → Controller
router.post("/orders", requireAuth, validateCreateOrder, createOrder);
router.patch("/orders/:id/status", requireAuth, validateOrderStatus, updateOrderStatus);

export default router;
```

## Benefits of This Architecture

### 1. **Single Responsibility**
- Each layer has one clear purpose
- Controllers only handle HTTP concerns
- Validation is separated and reusable
- Services focus on business logic

### 2. **Reusability**
- Validation middleware can be reused across routes
- Error handling is centralized
- Service logic can be called from multiple controllers

### 3. **Testability**
- Easy to test validation independently
- Easy to test controllers without validation logic
- Easy to test services without HTTP concerns

### 4. **Maintainability**
- Clear separation makes code easier to understand
- Changes to validation don't affect controllers
- Changes to business logic don't affect HTTP layer

### 5. **Consistency**
- All controllers follow the same pattern
- All validation follows the same pattern
- All error handling follows the same pattern

## Adding New Endpoints

### 1. Create Validation Middleware
```typescript
// src/middlewares/validation/myresource.validation.ts
export const validateCreateResource = (req, res, next) => {
  // Validate input
  // Return 400 if invalid
  // Call next() if valid
};
```

### 2. Update Controller (3 Steps Only)
```typescript
// src/controllers/myresource.controller.ts
export const createResource = async (req, res, next) => {
  try {
    // 1. Parse input
    const { field1, field2 } = req.body;

    // 2. Call service
    const result = await myService.create(field1, field2);

    // 3. Return response
    res.status(201).json(result);
  } catch (err) {
    try {
      handleServiceError(err, res);
    } catch (unhandledErr) {
      next(unhandledErr);
    }
  }
};
```

### 3. Attach Middleware in Routes
```typescript
// src/routes/myresource.routes.ts
router.post("/myresource", requireAuth, validateCreateResource, createResource);
```

## Best Practices

### ✅ DO:
- Keep controllers thin (< 15 lines per function)
- Use descriptive validation error messages
- Parse query params in validation middleware
- Attach parsed data to `req` for controller use
- Use meaningful HTTP status codes
- Let middleware handle all validation

### ❌ DON'T:
- Put validation in controllers
- Put business logic in controllers
- Access database from controllers
- Have complex error handling in controllers
- Repeat validation logic across endpoints

## Summary

This refactoring establishes a clean, maintainable architecture where:

1. **Routes** define endpoints and attach middleware
2. **Validation Middleware** validates input and returns 400 errors
3. **Controllers** parse → call → return (nothing else)
4. **Service Error Handler** maps service errors to HTTP codes
5. **Services** contain all business logic
6. **Repositories** handle database access

Each layer has a single, clear responsibility, making the codebase easier to understand, test, and maintain.


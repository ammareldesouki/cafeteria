/**
 * Repository Layer - Cart Data Access
 * Abstracts database operations for cart.
 * All MongoDB queries for cart live here. No business logic.
 */
import mongoose from "mongoose";
import { Cart, CartItem } from "@/types/cart.types";
import { ObjectId } from "mongodb";

const collection = mongoose.connection.collection<Cart>("carts");

export const cartRepository = {
  /**
   * Find cart by userId
   */
  async findByUserId(userId: string): Promise<Cart | null> {
    return collection.findOne({ userId });
  },

  /**
   * Create a new empty cart for a user
   */
  async create(userId: string): Promise<Cart> {
    const cart: Cart = {
      userId,
      items: [],
      totalItems: 0,
      totalPrice: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    const result = await collection.insertOne(cart as any);
    return { ...cart, _id: result.insertedId };
  },

  /**
   * Add a new item to the cart
   */
  async addItem(userId: string, item: CartItem): Promise<Cart | null> {
    return collection.findOneAndUpdate(
      { userId },
      {
        $push: { items: item } as any,
        $inc: {
          totalItems: item.quantity,
          totalPrice: item.subtotal,
        },
        $set: { updatedAt: new Date() },
      },
      { returnDocument: "after", upsert: true }
    );
  },

  /**
   * Increment quantity of an existing item (matched by menuItemId + variantName)
   */
  async incrementItem(
    userId: string,
    menuItemId: string,
    quantity: number,
    price: number,
    variantName?: string
  ): Promise<Cart | null> {
    // Build the filter to match the correct cart line
    const itemFilter =
      variantName !== undefined
        ? { menuItemId, variantName }
        : { menuItemId, variantName: { $exists: false } };

    return collection.findOneAndUpdate(
      { userId, items: { $elemMatch: itemFilter } },
      {
        $inc: {
          "items.$.quantity": quantity,
          "items.$.subtotal": price * quantity,
          totalItems: quantity,
          totalPrice: price * quantity,
        },
        $set: { updatedAt: new Date() },
      },
      { returnDocument: "after" }
    );
  },

  /**
   * Update quantity/notes of a cart item (matched by menuItemId + variantName)
   */
  async updateItem(
    userId: string,
    menuItemId: string,
    quantity: number,
    price: number,
    variantName?: string,
    notes?: string
  ): Promise<Cart | null> {
    const cart = await collection.findOne({ userId });
    if (!cart) return null;

    const existingItem = cart.items.find(
      (item) =>
        item.menuItemId === menuItemId &&
        (item.variantName ?? null) === (variantName ?? null)
    );
    if (!existingItem) return null;

    const quantityDiff = quantity - existingItem.quantity;
    const subtotalDiff = quantityDiff * price;
    const newSubtotal = quantity * price;

    const updateFields: any = {
      "items.$.quantity": quantity,
      "items.$.subtotal": newSubtotal,
      updatedAt: new Date(),
    };

    if (notes !== undefined) {
      updateFields["items.$.notes"] = notes;
    }

    const itemFilter =
      variantName !== undefined
        ? { menuItemId, variantName }
        : { menuItemId, variantName: { $exists: false } };

    return collection.findOneAndUpdate(
      { userId, items: { $elemMatch: itemFilter } },
      {
        $set: updateFields,
        $inc: {
          totalItems: quantityDiff,
          totalPrice: subtotalDiff,
        },
      },
      { returnDocument: "after" }
    );
  },

  /**
   * Remove a single item from the cart (matched by menuItemId + variantName)
   */
  async removeItem(
    userId: string,
    menuItemId: string,
    variantName?: string
  ): Promise<Cart | null> {
    const cart = await collection.findOne({ userId });
    if (!cart) return null;

    const item = cart.items.find(
      (i) =>
        i.menuItemId === menuItemId &&
        (i.variantName ?? null) === (variantName ?? null)
    );
    if (!item) return null;

    const pullFilter =
      variantName !== undefined
        ? { menuItemId, variantName }
        : { menuItemId, variantName: { $exists: false } };

    return collection.findOneAndUpdate(
      { userId },
      {
        $pull: { items: pullFilter } as any,
        $inc: {
          totalItems: -item.quantity,
          totalPrice: -item.subtotal,
        },
        $set: { updatedAt: new Date() },
      },
      { returnDocument: "after" }
    );
  },

  /**
   * Clear all items from the cart
   */
  async clearCart(userId: string): Promise<Cart | null> {
    return collection.findOneAndUpdate(
      { userId },
      {
        $set: {
          items: [],
          totalItems: 0,
          totalPrice: 0,
          updatedAt: new Date(),
        },
      },
      { returnDocument: "after" }
    );
  },
};
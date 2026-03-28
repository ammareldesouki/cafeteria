/**
 * Service Layer - Cart Business Logic
 * Handles all cart operations and coordinates with repository.
 */
import mongoose from "mongoose";
import { Cart, CartItem } from "@/types/cart.types";
import { cartRepository } from "@/repositories/cart.repository";
import { ObjectId } from "mongodb";

const menuCollection = mongoose.connection.collection("menu_items");

export const cartService = {
  /**
   * GET cart — fetch the user's cart, or create an empty one on first visit
   */
  async getCart(userId: string): Promise<Cart> {
    let cart = await cartRepository.findByUserId(userId);
    if (!cart) {
      cart = await cartRepository.create(userId);
    }
    return cart;
  },

  /**
   * POST /cart/items — add item, or increment quantity if already in cart
   * If item hasVariants, variantName is required and must exist in item.variants
   */
  async addItem(
    userId: string,
    menuItemId: string,
    quantity: number,
    variantName?: string,
    notes?: string
  ): Promise<Cart> {
    // Look up the menu item
    const menuItem = await menuCollection.findOne({
      _id: new ObjectId(menuItemId),
    });

    if (!menuItem) {
      throw new Error("Menu item not found");
    }

    // If item has variants, variantName is required
    if (menuItem.hasVariants) {
      if (!variantName) {
        throw new Error(
          `This item has variants. Please provide a variantName. Available: ${menuItem.variants
            .map((v: any) => v.name)
            .join(", ")}`
        );
      }

      // Check the variant actually exists on this item
      const variantExists = menuItem.variants?.some(
        (v: any) => v.name.toLowerCase() === variantName.toLowerCase()
      );

      if (!variantExists) {
        throw new Error(
          `Variant "${variantName}" not found. Available variants: ${menuItem.variants
            .map((v: any) => v.name)
            .join(", ")}`
        );
      }
    }

    // Make sure the user has a cart
    let cart = await cartRepository.findByUserId(userId);
    if (!cart) {
      cart = await cartRepository.create(userId);
    }

    // Check if same item + same variant already in cart → increment
    // Two Juhayna Mango and Juhayna Orange are treated as separate cart lines
    const existingItem = cart.items.find(
      (item) =>
        item.menuItemId === menuItemId &&
        (item.variantName ?? null) === (variantName ?? null)
    );

    if (existingItem) {
      const updated = await cartRepository.incrementItem(
        userId,
        menuItemId,
        quantity,
        menuItem.price,
        variantName
      );
      if (!updated) throw new Error("Failed to update cart");
      return updated;
    }

    // New item → push it
    const newItem: CartItem = {
      menuItemId,
      name: menuItem.name,
      price: menuItem.price,
      image: menuItem.image,
      category: menuItem.category,
      quantity,
      variantName: variantName ?? undefined,
      notes,
      subtotal: menuItem.price * quantity,
    };

    const updated = await cartRepository.addItem(userId, newItem);
    if (!updated) throw new Error("Failed to add item to cart");
    return updated;
  },

  /**
   * PATCH /cart/items/:menuItemId — set exact quantity and/or notes
   * Optionally pass variantName in body to target the right cart line
   */
  async updateItem(
    userId: string,
    menuItemId: string,
    quantity: number,
    variantName?: string,
    notes?: string
  ): Promise<Cart> {
    const cart = await cartRepository.findByUserId(userId);
    if (!cart) throw new Error("Cart not found");

    const existingItem = cart.items.find(
      (item) =>
        item.menuItemId === menuItemId &&
        (item.variantName ?? null) === (variantName ?? null)
    );

    if (!existingItem) throw new Error("Item not found in cart");

    const updated = await cartRepository.updateItem(
      userId,
      menuItemId,
      quantity,
      existingItem.price,
      variantName,
      notes
    );

    if (!updated) throw new Error("Failed to update item");
    return updated;
  },

  /**
   * DELETE /cart/items/:menuItemId — remove one item (by menuItemId + optional variantName)
   */
  async removeItem(
    userId: string,
    menuItemId: string,
    variantName?: string
  ): Promise<Cart> {
    const updated = await cartRepository.removeItem(userId, menuItemId, variantName);
    if (!updated) throw new Error("Cart or item not found");
    return updated;
  },

  /**
   * DELETE /cart — empty the entire cart
   */
  async clearCart(userId: string): Promise<{ message: string }> {
    await cartRepository.clearCart(userId);
    return { message: "Cart cleared successfully" };
  },
};
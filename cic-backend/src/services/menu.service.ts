/**
 * Service Layer - Business Logic
 * Orchestrates menu operations. Calls repositories for data.
 * Add filtering, caching, validation rules here.
 */
import { menuRepository } from "@/repositories/menu.repository";

export const menuService = {
  async getAllMenuItems() {
    const items = await menuRepository.findAll();

    return items.map((item: any) => ({
      ...item,
      in_stock: item?.in_stock !== false,
    }));
  },

  async updateItemStock(itemId: string, inStock: boolean) {
    const updated = await menuRepository.updateItemStock(itemId, inStock);

    if (!updated) {
      throw new Error("Menu item not found");
    }

    return updated;
  },
};

import { ObjectId } from "mongodb";

export interface CartItem {
  menuItemId: string;
  name: string;
  price: number;
  image?: string;
  category?: string;
  quantity: number;
  variantName?: string; // e.g. "Mango", "Cheese" — only for items where hasVariants: true
  notes?: string;
  subtotal: number;
}

export interface Cart {
  _id?: ObjectId;
  userId: string;
  items: CartItem[];
  totalItems: number;
  totalPrice: number;
  createdAt: Date;
  updatedAt: Date;
}
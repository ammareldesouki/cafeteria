/**
 * Type definitions for Orders
 */
import { ObjectId } from "mongodb";

export enum OrderStatus {
  PENDING = "pending",
  COMPLETED = "completed",
  CANCELLED = "cancelled",
}

export enum PaymentStatus {
  PAID = "paid",
  UNPAID = "unpaid",
}

export interface Order {
  _id?: ObjectId;
  userId: string;
  userEmail: string;
  itemIds: string[];
  total: number;
  deliveryLocation: string;
  status: OrderStatus;
  paymentStatus: PaymentStatus;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Service Layer - Orders Business Logic
 * Orchestrates order operations. Validates items exist, manages order lifecycle.
 */
import { orderRepository } from "@/repositories/order.repository";
import { Order, OrderStatus, PaymentStatus } from "@/types/order.types";
import { walletService } from "@/services/wallet.service";
import mongoose from "mongoose";
import { ObjectId } from "mongodb";

const menuCollection = mongoose.connection.collection("menu_items");

export const orderService = {
  /**
   * Create a new order
   * Validates that all menu items exist before creating
   */
  async createOrder(
    userId: string,
    userEmail: string,
    itemIds: string[],
    total: number,
    deliveryLocation: string,
  ): Promise<Order> {
    // Validate all menu items exist
    const objectIds = itemIds.map((id) => new ObjectId(id));
    const items = await menuCollection
      .find({ _id: { $in: objectIds } })
      .toArray();

    if (items.length !== itemIds.length) {
      throw new Error("One or more menu items not found");
    }

    const order: Order = {
      userId,
      userEmail,
      itemIds,
      total,
      deliveryLocation,
      status: OrderStatus.PENDING,
      paymentStatus: PaymentStatus.UNPAID,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    return orderRepository.create(order);
  },

  /**
   * Get all orders for a user
   */
  async getUserOrders(userId: string): Promise<Order[]> {
    return orderRepository.findByUserId(userId);
  },

  /**
   * Get a single order by ID
   * Includes user ownership check
   */
  async getOrderById(orderId: string, userId: string): Promise<Order> {
    const order = await orderRepository.findById(orderId);

    if (!order) {
      throw new Error("Order not found");
    }

    // Authorization check - user can only access their own orders
    if (order.userId !== userId) {
      throw new Error("Unauthorized");
    }

    return order;
  },

  /**
   * Update order status
   * Includes user ownership check
   */
  async updateOrderStatus(
    orderId: string,
    userId: string,
    status: OrderStatus,
  ): Promise<Order> {
    // First check ownership
    const order = await orderRepository.findById(orderId);

    if (!order) {
      throw new Error("Order not found");
    }

    if (order.userId !== userId) {
      throw new Error("Unauthorized");
    }

    const updated = await orderRepository.updateStatus(orderId, status);
    if (!updated) {
      throw new Error("Failed to update order status");
    }

    return updated;
  },

  /**
   * Update payment status
   * Includes user ownership check
   */
  async updateOrderPayment(
    orderId: string,
    userId: string,
    paymentStatus: PaymentStatus,
  ): Promise<Order> {
    // First check ownership
    const order = await orderRepository.findById(orderId);

    if (!order) {
      throw new Error("Order not found");
    }

    if (order.userId !== userId) {
      throw new Error("Unauthorized");
    }

    const updated = await orderRepository.updatePaymentStatus(
      orderId,
      paymentStatus,
    );
    if (!updated) {
      throw new Error("Failed to update payment status");
    }

    return updated;
  },

  /**
   * Get all orders with filters and pagination (admin only)
   */
  async getAllOrders(
    filters: {
      userId?: string;
      paymentStatus?: PaymentStatus;
      status?: OrderStatus;
    },
    page: number = 1,
    limit: number = 10,
  ): Promise<{
    data: Order[];
    totalCount: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    // Ensure limit doesn't exceed 1000
    const maxLimit = Math.min(limit, 1000);

    const [orders, totalCount] = await Promise.all([
      orderRepository.findAllPaginated(page, maxLimit, filters),
      orderRepository.countWithFilters(filters),
    ]);

    return {
      data: orders,
      totalCount,
      page,
      limit: maxLimit,
      totalPages: Math.ceil(totalCount / maxLimit),
    };
  },

  /**
   * Update order by admin (no ownership check)
   * Automatically updates wallet when payment status changes
   */
  async updateOrderByAdmin(
    orderId: string,
    updates: {
      status?: OrderStatus;
      paymentStatus?: PaymentStatus;
    },
  ): Promise<Order> {
    const order = await orderRepository.findById(orderId);

    if (!order) {
      throw new Error("Order not found");
    }

    // Track original state for wallet logic
    const originalStatus = order.status;
    const originalPaymentStatus = order.paymentStatus;

    // Update status if provided
    if (updates.status !== undefined) {
      const updated = await orderRepository.updateStatus(
        orderId,
        updates.status,
      );
      if (!updated) {
        throw new Error("Failed to update order status");
      }
      // Refresh order object
      Object.assign(order, updated);
    }

    // Update payment status if provided
    if (updates.paymentStatus !== undefined) {
      const updated = await orderRepository.updatePaymentStatus(
        orderId,
        updates.paymentStatus,
      );
      if (!updated) {
        throw new Error("Failed to update payment status");
      }
      // Refresh order object
      Object.assign(order, updated);
    }

    // Get final state
    const finalOrder = await orderRepository.findById(orderId);
    if (!finalOrder) {
      throw new Error("Order not found after update");
    }

    // === WALLET INTEGRATION ===
    // Automatically update wallet when payment status changes

    const paymentStatusChanged =
      updates.paymentStatus !== undefined &&
      originalPaymentStatus !== updates.paymentStatus;

    const statusChanged =
      updates.status !== undefined && originalStatus !== updates.status;

    // Case 1: Payment status explicitly changed from unpaid → paid
    if (
      paymentStatusChanged &&
      originalPaymentStatus === PaymentStatus.UNPAID &&
      updates.paymentStatus === PaymentStatus.PAID
    ) {
      await walletService.recordPayment(orderId, finalOrder.total);
    }
    // Case 2: Payment status explicitly changed from paid → unpaid (reversal)
    else if (
      paymentStatusChanged &&
      originalPaymentStatus === PaymentStatus.PAID &&
      updates.paymentStatus === PaymentStatus.UNPAID
    ) {
      await walletService.recordDelivery(orderId, finalOrder.total);
    }
    // Case 3: Order marked completed while still unpaid (delivered unpaid / credit)
    // This happens when status changes to completed AND payment is unpaid
    else if (
      statusChanged &&
      updates.status === OrderStatus.COMPLETED &&
      finalOrder.paymentStatus === PaymentStatus.UNPAID &&
      originalPaymentStatus === PaymentStatus.UNPAID
    ) {
      await walletService.recordDelivery(orderId, finalOrder.total);
    }
    // Case 4: Both status and payment changed to completed+paid simultaneously
    else if (
      statusChanged &&
      paymentStatusChanged &&
      updates.status === OrderStatus.COMPLETED &&
      updates.paymentStatus === PaymentStatus.PAID
    ) {
      await walletService.recordPayment(orderId, finalOrder.total);
    }


    return finalOrder;
  },
};

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../manager/order_bloc.dart';
import '../manager/order_event.dart';
import '../manager/order_state.dart';
import '../widgets/order_status_tracker.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(GetOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            // ── Body ──
            Expanded(
              child: BlocConsumer<OrderBloc, OrderState>(
                listener: (context, state) {
                  if (state is OrderCancelled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.orderCancelled),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                    );
                  }
                  if (state is OrderError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF3B1A08)),
                    );
                  }

                  final orders = _extractOrders(state);

                  if (orders == null || orders.isEmpty) {
                    return _EmptyOrders(
                      onRefresh: () =>
                          context.read<OrderBloc>().add(GetOrdersEvent()),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF3B1A08),
                    onRefresh: () async =>
                        context.read<OrderBloc>().add(RefreshOrdersEvent()),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final isActionLoading = state is OrderActionLoading &&
                            state.actionOrderId == order.id;
                        return _OrderCard(
                          order: order,
                          isActionLoading: isActionLoading,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<OrderEntity>? _extractOrders(OrderState state) {
    if (state is OrdersLoaded) return state.orders;
    if (state is OrderActionLoading) return state.orders;
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Order Card
// ═══════════════════════════════════════════════════════════════════════════

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final bool isActionLoading;

  const _OrderCard({
    required this.order,
    required this.isActionLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8D7BF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Order ID + Status badge ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.orderNumber} #${order.id.substring(
                            order.id.length > 10 ? order.id.length - 10 : 0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B1A08),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MM/dd/yyyy, h:mm:ss a')
                            .format(order.createdAt.toLocal()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B7355),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),

            const SizedBox(height: 16),

            // ── Items list ──
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.quantity}x ${item.menuItemName ?? l10n.item}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF3B1A08),
                          ),
                        ),
                        if (item.variantName != null)
                          Text(
                            item.variantName!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8B7355),
                            ),
                          ),
                        if (item.sugar != null)
                          Text(
                            '${l10n.sugar}: ${l10n.sugarSpoons(item.sugar!)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8B7355),
                            ),
                          ),
                        if (item.selectedExtras != null &&
                            item.selectedExtras!.isNotEmpty)
                          ...item.selectedExtras!.map((e) => Text(
                                '+ ${e.name} (+${e.price.toStringAsFixed(2)} ${AppLocalizations.of(context)!.pound})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFC07722),
                                ),
                              )),
                        if (item.note != null && item.note!.isNotEmpty)
                          Text(
                            '${l10n.specialInstructions}: ${item.note}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8B7355),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.subtotal.toStringAsFixed(2)}${AppLocalizations.of(
                        context)!.pound}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B1A08),
                    ),
                  ),
                ],
              ),
            )),

            // ── Delivery location ──
            if (order.deliveryLocation != null &&
                order.deliveryLocation!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: Color(0xFFC07722)),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.deliveryAddress}: ${order.deliveryLocation}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFC07722),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // ── Total ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B1A08),
                  ),
                ),
                Text(
                  '${order.totalPrice.toStringAsFixed(2)} ${AppLocalizations.of(
                      context)!.pound}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC07722),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Status tracker ──
            OrderStatusTracker(status: order.status),

            // ── Cancel button ──
            if (order.canCancel) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: isActionLoading
                      ? null
                      : () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE57373)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isActionLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE57373),
                    ),
                  )
                      : Text(
                    l10n.cancelOrder,
                    style: const TextStyle(
                      color: Color(0xFFE57373),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.cancelOrder,
          style: const TextStyle(
            color: Color(0xFF3B1A08),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.cancelOrderConfirm,
              style: const TextStyle(color: Color(0xFF8B7355)),
            ),
            const SizedBox(height: 24),
            // Two equal-width buttons, side by side.
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD9C7B8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(color: Color(0xFF8B7355)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<OrderBloc>().add(CancelOrderEvent(order.id));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE57373),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.confirm,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Status Badge
// ═══════════════════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  String _localizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    return switch (status) {
      'pending' => l10n.orderConfirmed,
      'processing' => l10n.orderPreparing,
      'completed' => l10n.orderReady,
      'delivered' => l10n.orderDelivered,
      'cancelled' => l10n.orderCancelled,
      _ => status[0].toUpperCase() + status.substring(1),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = switch (status) {
      'pending' => (
      const Color(0xFFFFF3E0),
      const Color(0xFFE65100),
      Icons.schedule_rounded
      ),
      'processing' => (
      const Color(0xFFE3F2FD),
      const Color(0xFF1565C0),
      Icons.local_fire_department_rounded
      ),
      'completed' => (
      const Color(0xFFE8F5E9),
      const Color(0xFF2E7D32),
      Icons.check_circle_rounded
      ),
      'delivered' => (
      const Color(0xFFE8F5E9),
      const Color(0xFF2E7D32),
      Icons.check_circle_rounded
      ),
      'cancelled' => (
      const Color(0xFFFCE4EC),
      const Color(0xFFC62828),
      Icons.cancel_rounded
      ),
      _ => (
      const Color(0xFFF5F5F5),
      const Color(0xFF616161),
      Icons.help_rounded
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            _localizedStatus(context, status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Empty State
// ═══════════════════════════════════════════════════════════════════════════

class _EmptyOrders extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyOrders({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFFF0E8DC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Color(0xFF9E7E65),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.myOrders,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B1A08),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.orderHistory,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8B7355)),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B1A08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                      Icons.refresh_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.refresh,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
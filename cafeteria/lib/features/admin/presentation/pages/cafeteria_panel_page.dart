import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../manager/admin_bloc.dart';
import '../manager/admin_event.dart';
import '../manager/admin_state.dart';
import '../../../auth/di/injaction.dart';

class CafeteriaPanelPage extends StatefulWidget {
  const CafeteriaPanelPage({super.key});

  @override
  State<CafeteriaPanelPage> createState() => _CafeteriaPanelPageState();
}

class _CafeteriaPanelPageState extends State<CafeteriaPanelPage> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedDateRange;
  String? _selectedPaymentStatus;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadDashboardDataEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _fetchFilteredOrders();
  }

  void _fetchFilteredOrders() {
    context.read<AdminBloc>().add(
      FetchAdminOrdersEvent(
        page: 1,
        limit: 100,
        search: _searchController.text,
        dateRange: _selectedDateRange,
        paymentStatus: _selectedPaymentStatus,
      ),
    );
  }

  void _showFilterBottomsheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filter Orders By",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text("All Orders"),
                onTap: () {
                  _selectedPaymentStatus = null;
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
              ListTile(
                title: const Text("Unpaid Only"),
                onTap: () {
                  _selectedPaymentStatus = 'unpaid';
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
              ListTile(
                title: const Text("Paid Only"),
                onTap: () {
                  _selectedPaymentStatus = 'paid';
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDateFilterBottomsheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filter Date",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text("All Time"),
                onTap: () {
                  _selectedDateRange = null;
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
              ListTile(
                title: const Text("Today"),
                onTap: () {
                  _selectedDateRange = 'today';
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
              ListTile(
                title: const Text("This Week"),
                onTap: () {
                  _selectedDateRange = 'week';
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
              ListTile(
                title: const Text("This Month"),
                onTap: () {
                  _selectedDateRange = 'month';
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is AdminInitial ||
                (state is AdminLoading &&
                    context.read<AdminBloc>().state is! AdminDashboardLoaded)) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentState = state is AdminDashboardLoaded
                ? state
                : (context.read<AdminBloc>().state
                      as AdminDashboardLoaded); // fallback safely

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cafeteria Panel",
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Order Management",
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: TColors.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Analytics Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.2,
                    children: [
                      _buildStatCard(
                        "Active Orders",
                        currentState.analytics.activeOrders.toString(),
                        Icons.access_time,
                      ),
                      _buildStatCard(
                        "Total Orders",
                        currentState.analytics.totalOrders.toString(),
                        Icons.check_circle_outline,
                      ),
                      _buildStatCard(
                        "Revenue",
                        "\$${currentState.analytics.totalRevenue.toStringAsFixed(2)}",
                        Icons.attach_money,
                        color: TColors.primary,
                      ),
                      _buildStatCard(
                        "Pending",
                        "\$${currentState.analytics.pendingRevenue.toStringAsFixed(2)}",
                        Icons.money_off,
                        color: TColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Orders Headers and Filters
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Orders (${currentState.orders.totalCount})",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.filter_alt_outlined),
                            onPressed: _showFilterBottomsheet,
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today_outlined),
                            onPressed: _showDateFilterBottomsheet,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Bar
                  TextFormField(
                    controller: _searchController,
                    onFieldSubmitted: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search by username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List of Orders
                  if (currentState.orders.data.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("No orders found."),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentState.orders.data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildAdminOrderCard(
                          currentState.orders.data[index],
                        );
                      },
                    ),
                  const SizedBox(height: 48), // Bottom padding
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon, {
    Color color = Colors.black87,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOrderCard(OrderEntity order) {
    // Determine button text and action
    String adminActionText = '';
    Color adminActionColor = TColors.primary;
    VoidCallback? adminAction;

    if (order.status == 'pending') {
      adminActionText = 'Start Preparation';
      adminAction = () {
        context.read<AdminBloc>().add(
          UpdateAdminOrderEvent(orderId: order.id, status: 'processing'),
        );
      };
    } else if (order.status == 'processing') {
      adminActionText = 'Mark Completed / Prepared';
      adminActionColor = Colors.orange;
      adminAction = () {
        context.read<AdminBloc>().add(
          UpdateAdminOrderEvent(orderId: order.id, status: 'completed'),
        );
      };
    } else if (order.status == 'completed') {
      adminActionText = 'Mark Delivered';
      adminActionColor = Colors.orange.shade700;
      adminAction = () {
        context.read<AdminBloc>().add(
          UpdateAdminOrderEvent(orderId: order.id, status: 'delivered'),
        );
      };
    } else if (order.paymentStatus == 'unpaid' && order.status != 'cancelled') {
      adminActionText = 'Mark Paid';
      adminActionColor = Colors.green;
      adminAction = () {
        context.read<AdminBloc>().add(
          UpdateAdminOrderEvent(orderId: order.id, paymentStatus: 'paid'),
        );
      };
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${order.id.substring(max(0, order.id.length - 8))}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: order.paymentStatus == 'paid'
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.paymentStatus.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Details
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  order.userName?.toUpperCase() ?? "UNKNOWN",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.business_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(order.deliveryLocation ?? "Pickup"),
              ],
            ),
            if (order.userPhone != null && order.userPhone!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(order.userPhone!),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(DateFormat('hh:mm a').format(order.createdAt)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.attach_money_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  "\$${order.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order Items
            if (order.items.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                "Order Items:",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              ...order.items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.menuItemName ?? 'Item',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (item.variantName != null)
                                  Text(
                                    "Variant: ${item.variantName}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                Text(
                                  "Qty: ${item.quantity}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (item.note != null && item.note!.isNotEmpty)
                                  Text(
                                    "Note: ${item.note}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            "\$${item.subtotal.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],

            // Action Buttons
            if (adminActionText.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: adminAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: adminActionColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    adminActionText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],

            // Always allow explicit cancellation for admins if it's not Delivered or Cancelled
            if (order.status != 'cancelled' && order.status != 'delivered') ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    context.read<AdminBloc>().add(
                      UpdateAdminOrderEvent(
                        orderId: order.id,
                        status: 'cancelled',
                      ),
                    );
                  },
                  child: const Text(
                    "Cancel Order",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.grey.shade800;
      case 'processing':
        return Colors.orange;
      case 'completed':
        return Colors.green.shade400;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

int max(int a, int b) {
  // Helper since dart:math is missing if we don't import
  return a > b ? a : b;
}

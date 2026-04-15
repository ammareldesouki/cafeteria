import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../home/domain/entities/menu_item_entity.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Orders", icon: Icon(Icons.shopping_bag_outlined)),
              Tab(text: "Menu / Stock", icon: Icon(Icons.restaurant_menu)),
            ],
            indicatorColor: TColors.primary,
            labelColor: TColors.primary,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return ListenableBuilder(
              listenable: DefaultTabController.of(context),
              builder: (context, _) {
                if (DefaultTabController
                    .of(context)
                    .index == 1) {
                  return FloatingActionButton(
                    onPressed: () => _showAddEditItemSheet(),
                    backgroundColor: TColors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
        body: TabBarView(
          children: [
            _buildOrdersTab(),
            _buildMenuTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return SafeArea(
      child: BlocConsumer<AdminBloc, AdminState>(
        listener: _adminListener,
        builder: (context, state) {
          final lastDashboard = context
              .read<AdminBloc>()
              .lastDashboardState;

          if (state is AdminInitial && lastDashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminLoading && lastDashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentState =
          state is AdminDashboardLoaded ? state : lastDashboard;

          if (currentState == null) {
            // Safety net: if we ever got here without a loaded dashboard, trigger load.
            context.read<AdminBloc>().add(LoadDashboardDataEvent());
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Header
                _buildHeader("Cafeteria Panel", "Order Management"),
                const SizedBox(height: 24),

                // Analytics Grid
                _buildAnalyticsGrid(currentState),
                const SizedBox(height: 24),

                // Orders Headers and Filters
                _buildOrdersHeader(currentState),
                const SizedBox(height: 12),

                // Search Bar
                _buildSearchBar(
                  _searchController,
                  _onSearchChanged,
                  "Search by username",
                ),
                const SizedBox(height: 16),

                // List of Orders
                if (currentState.orders.data.isEmpty)
                  _buildEmptyState("No orders found.")
                else
                  _buildOrdersList(currentState),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuTab() {
    return BlocConsumer<AdminBloc, AdminState>(
      listener: _adminListener,
      builder: (context, state) {
        final lastMenu = _lastMenuState;

        if (state is AdminLoading && lastMenu == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! AdminMenuLoaded && lastMenu == null) {
          context.read<AdminBloc>().add(FetchAdminMenuEvent());
          return const Center(child: CircularProgressIndicator());
        }

        final items = state is AdminMenuLoaded ? state.items : lastMenu!.items;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AdminBloc>().add(FetchAdminMenuEvent());
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader("Menu Admin", "Manage Items & Stock"),
                const SizedBox(height: 24),

                // Summary/Stats for menu if needed
                Text(
                  "Items (${items.length})",
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                if (items.isEmpty)
                  _buildEmptyState("No menu items found.")
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildMenuItemAdminCard(items[index]);
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  AdminMenuLoaded? get _lastMenuState {
    final state = context
        .read<AdminBloc>()
        .state;
    if (state is AdminMenuLoaded) return state;
    return context
        .read<AdminBloc>()
        .lastMenuState;
  }

  void _adminListener(BuildContext context, AdminState state) {
    if (state is AdminError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 20,
          backgroundColor: TColors.primary,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAnalyticsGrid(AdminDashboardLoaded state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _buildStatCard("Active Orders", state.analytics.activeOrders.toString(),
            Icons.access_time),
        _buildStatCard("Total Orders", state.analytics.totalOrders.toString(),
            Icons.check_circle_outline),
        _buildStatCard(
            "Revenue", "\$${state.analytics.totalRevenue.toStringAsFixed(2)}",
            Icons.attach_money, color: TColors.primary),
        _buildStatCard(
            "Pending", "\$${state.analytics.pendingRevenue.toStringAsFixed(2)}",
            Icons.money_off, color: TColors.secondary),
      ],
    );
  }

  Widget _buildOrdersHeader(AdminDashboardLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Orders (${state.orders.totalCount})",
          style: Theme
              .of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.filter_alt_outlined),
                onPressed: _showFilterBottomsheet),
            IconButton(icon: const Icon(Icons.calendar_today_outlined),
                onPressed: _showDateFilterBottomsheet),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(TextEditingController controller,
      Function(String) onSubmitted, String hint) {
    return TextFormField(
      controller: controller,
      onFieldSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(AdminDashboardLoaded state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.orders.data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _buildAdminOrderCard(state.orders.data[index]),
    );
  }

  Widget _buildMenuItemAdminCard(MenuItemEntity item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade100,
                      child: const Icon(
                          Icons.fastfood_outlined, color: Colors.grey),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${item.price.toStringAsFixed(2)} EGP • ${item.category}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _buildStockBadge(item),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(
                      Icons.edit_outlined, color: TColors.primary, size: 20),
                  onPressed: () => _showAddEditItemSheet(item),
                ),
                IconButton(
                  icon: const Icon(
                      Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _confirmDelete(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(MenuItemEntity item) {
    final bool hasVariants = item.hasVariants == true;
    final String label = hasVariants ? "VARIANTS STOCK" : "STOCK: ${item
        .stock ?? 0}";
    final Color color = (hasVariants || (item.stock ?? 0) > 0)
        ? Colors.green
        : Colors.red;

    return InkWell(
      onTap: () => _showStockManagementSheet(item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showStockManagementSheet(MenuItemEntity item) {
    final TextEditingController stockController = TextEditingController(
        text: (item.stock ?? 0).toString());
    final adminBloc = context.read<AdminBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery
              .of(ctx)
              .viewInsets
              .bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Manage Stock: ${item.name}", style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge),
              const SizedBox(height: 20),
              if (item.hasVariants == true && item.variants != null)
                ...item.variants!.map((v) {
                  final variantController = TextEditingController(
                      text: (v.stock ?? 0).toString());
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(child: Text(v.name, style: const TextStyle(
                            fontWeight: FontWeight.w500))),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: variantController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Stock", isDense: true),
                            onFieldSubmitted: (val) {
                              adminBloc.add(SetVariantStockEvent(
                                itemId: item.mongoId ?? item.id,
                                variantName: v.name,
                                stock: int.tryParse(val) ?? 0,
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
              else
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Current Stock", border: OutlineInputBorder()),
                ),
              const SizedBox(height: 24),
              if (item.hasVariants != true)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      adminBloc.add(SetItemStockEvent(
                        itemId: item.mongoId ?? item.id,
                        stock: int.tryParse(stockController.text) ?? 0,
                      ));
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary),
                    child: const Text(
                        "Save Stock", style: TextStyle(color: Colors.white)),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAddEditItemSheet([MenuItemEntity? item]) {
    final nameController = TextEditingController(text: item?.name);
    final priceController = TextEditingController(text: item?.price.toString());
    final categoryController = TextEditingController(text: item?.category);
    final descController = TextEditingController(text: item?.description);
    final imageController = TextEditingController(text: item?.image);
    final stockController =
    TextEditingController(text: item?.stock?.toString() ?? "0");
    bool hasVariants = item?.hasVariants ?? false;
    final variantNameControllers = <TextEditingController>[];
    final variantStockControllers = <TextEditingController>[];
    final adminBloc = context.read<AdminBloc>();

    if (item == null && hasVariants) {
      variantNameControllers.add(TextEditingController());
      variantStockControllers.add(TextEditingController(text: "0"));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (stfContext, setState) {
            void ensureVariantRow() {
              if (variantNameControllers.isEmpty) {
                variantNameControllers.add(TextEditingController());
                variantStockControllers.add(TextEditingController(text: "0"));
              }
            }

            void addVariantRow() {
              variantNameControllers.add(TextEditingController());
              variantStockControllers.add(TextEditingController(text: "0"));
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery
                  .of(ctx)
                  .viewInsets
                  .bottom, left: 24, right: 24, top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item == null ? "Add New Item" : "Edit Item",
                        style: Theme
                            .of(stfContext)
                            .textTheme
                            .titleLarge),
                    const SizedBox(height: 20),
                    TextFormField(controller: nameController,
                        decoration: const InputDecoration(
                            labelText: "Item Name")),
                    const SizedBox(height: 12),
                    TextFormField(controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Price")),
                    const SizedBox(height: 12),
                    TextFormField(controller: categoryController,
                        decoration: const InputDecoration(
                            labelText: "Category (e.g. drinks, snacks)")),
                    const SizedBox(height: 12),
                    TextFormField(controller: descController,
                        decoration: const InputDecoration(
                            labelText: "Description")),
                    const SizedBox(height: 12),
                    TextFormField(controller: imageController,
                        decoration: const InputDecoration(
                            labelText: "Image URL")),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text("Has Variants?"),
                      value: hasVariants,
                      onChanged: (val) =>
                          setState(() {
                            hasVariants = val;
                            if (item == null && hasVariants) {
                              ensureVariantRow();
                            }
                            if (item == null && !hasVariants) {
                              variantNameControllers.clear();
                              variantStockControllers.clear();
                            }
                          }),
                    ),
                    if (item == null) ...[
                      const SizedBox(height: 12),
                      if (!hasVariants)
                        TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Stock",
                            border: OutlineInputBorder(),
                          ),
                        )
                      else
                        ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Variants",
                              style: Theme
                                  .of(stfContext)
                                  .textTheme
                                  .titleMedium,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(variantNameControllers.length, (i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: variantNameControllers[i],
                                      decoration: InputDecoration(
                                        labelText: "Variant name",
                                        border: const OutlineInputBorder(),
                                        suffixIcon: i == 0
                                            ? null
                                            : IconButton(
                                          tooltip: "Remove",
                                          onPressed: () =>
                                              setState(() {
                                                variantNameControllers
                                                    .removeAt(i);
                                                variantStockControllers
                                                    .removeAt(i);
                                              }),
                                          icon: const Icon(Icons.close),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: variantStockControllers[i],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: "Stock",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => setState(addVariantRow),
                              icon: const Icon(Icons.add),
                              label: const Text("More variants"),
                            ),
                          ),
                        ],
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (item == null) {
                            final variants = hasVariants
                                ? List.generate(variantNameControllers.length,
                                    (i) {
                                  final name =
                                  variantNameControllers[i].text.trim();
                                  final stock = int.tryParse(
                                      variantStockControllers[i].text) ??
                                      0;
                                  return VariantEntity(
                                      name: name, stock: stock);
                                }).where((v) =>
                            v.name
                                .trim()
                                .isNotEmpty).toList()
                                : null;

                            adminBloc.add(CreateMenuItemEvent(
                              name: nameController.text,
                              price: double.tryParse(priceController.text) ??
                                  0.0,
                              category: categoryController.text,
                              description: descController.text,
                              image: imageController.text,
                              hasVariants: hasVariants,
                              stock: hasVariants
                                  ? 0
                                  : (int.tryParse(stockController.text) ?? 0),
                              variants: variants,
                            ));
                          } else {
                            adminBloc.add(UpdateMenuItemEvent(
                              itemId: item.mongoId ?? item.id,
                              name: nameController.text,
                              price: double.tryParse(priceController.text),
                              category: categoryController.text,
                              description: descController.text,
                              image: imageController.text,
                              hasVariants: hasVariants,
                            ));
                          }
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: TColors
                            .primary),
                        child: Text(item == null ? "Add Item" : "Update Item",
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(MenuItemEntity item) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text("Delete Item?"),
            content: Text("Are you sure you want to delete ${item.name}?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  context.read<AdminBloc>().add(
                      DeleteMenuItemEvent(item.mongoId ?? item.id));
                  Navigator.pop(ctx);
                },
                child: const Text(
                    "Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
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

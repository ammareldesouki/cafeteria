import 'dart:async';
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
import '../../../auth/presentation/manager/auth_bloc.dart';
import '../../../auth/presentation/widgets/language_theme_toggles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/route/route_name.dart';
import '../../../auth/di/injaction.dart';
import 'pending_revenue_page.dart';

class CafeteriaPanelPage extends StatefulWidget {
  const CafeteriaPanelPage({super.key});

  @override
  State<CafeteriaPanelPage> createState() => _CafeteriaPanelPageState();
}

class _CafeteriaPanelPageState extends State<CafeteriaPanelPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  String? _selectedDateRange;
  String? _selectedPaymentStatus;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadDashboardDataEvent());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Live search: re-query as the user types, debounced so we don't hit the
  /// API on every keystroke.
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _fetchFilteredOrders();
    });
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
    final l10n = AppLocalizations.of(context)!;
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
              Text(l10n.filter, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                title: Text(l10n.allItems),
                onTap: () {
                  _selectedPaymentStatus = null;
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
              ListTile(
                title: Text(l10n.unpaidOnly),
                onTap: () {
                  _selectedPaymentStatus = 'unpaid';
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
              ListTile(
                title: Text(l10n.paidOnly),
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
    final l10n = AppLocalizations.of(context)!;
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
              Text(l10n.filterDate, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                title: Text(l10n.allTime),
                onTap: () {
                  _selectedDateRange = null;
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
              ListTile(
                title: Text(l10n.today),
                onTap: () {
                  _selectedDateRange = 'today';
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
              ListTile(
                title: Text(l10n.thisWeek),
                onTap: () {
                  _selectedDateRange = 'week';
                  Navigator.pop(ctx);
                  _fetchFilteredOrders();
                },
              ),
              ListTile(
                title: Text(l10n.thisMonth),
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
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UserSignedOut) {
          Navigator.pushNamedAndRemoveUntil(
              context, RouteNames.signIn, (route) => false);
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: TabBar(
              tabs: [
                Tab(text: l10n.myOrders, icon: const Icon(Icons.shopping_bag_outlined)),
                Tab(text: l10n.menu, icon: const Icon(Icons.restaurant_menu)),
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
                  if (DefaultTabController.of(context).index == 1) {
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
      ),
    );
  }

  Widget _buildOrdersTab() {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: BlocConsumer<AdminBloc, AdminState>(
        listener: _adminListener,
        builder: (context, state) {
          final lastDashboard = context.read<AdminBloc>().lastDashboardState;

          if (state is AdminInitial && lastDashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminLoading && lastDashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentState =
          state is AdminDashboardLoaded ? state : lastDashboard;

          if (currentState == null) {
            context.read<AdminBloc>().add(LoadDashboardDataEvent());
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(l10n.appName, l10n.orderHistory),
                const SizedBox(height: 24),
                _buildAnalyticsGrid(currentState),
                const SizedBox(height: 24),
                _buildOrdersHeader(currentState),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSearchBar(
                        _searchController,
                        _onSearchChanged,
                        l10n.searchPlaceholder,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Opens the Pending Revenue (debt-by-user) screen.
                    GestureDetector(
                      onTap: _openPendingRevenue,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B1A08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.groups_rounded,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (currentState.orders.data.isEmpty)
                  _buildEmptyState(l10n.noResultsFound)
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
    final l10n = AppLocalizations.of(context)!;

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
                _buildHeader(l10n.menu, l10n.outOfStock),
                const SizedBox(height: 24),
                Text(
                  "${l10n.menu} (${items.length})",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  _buildEmptyState(l10n.noResultsFound)
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
    final state = context.read<AdminBloc>().state;
    if (state is AdminMenuLoaded) return state;
    return context.read<AdminBloc>().lastMenuState;
  }

  void _adminListener(BuildContext context, AdminState state) {
    if (state is AdminError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                const LanguageThemeToggles(),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOutEvent());
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  tooltip: AppLocalizations.of(context)?.logout,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  Widget _buildAnalyticsGrid(AdminDashboardLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _buildStatCard(l10n.activeOrder,
            state.analytics.activeOrders.toString(), Icons.access_time),
        _buildStatCard(l10n.totalOrder,
            state.analytics.totalOrders.toString(), Icons.check_circle_outline),
        _buildStatCard(
            l10n.rvenue,
            "\$${state.analytics.totalRevenue.toStringAsFixed(2)}",
            Icons.attach_money,
            color: TColors.primary),
        _buildStatCard(
            l10n.pendingWallet,
            "\$${state.analytics.pendingRevenue.toStringAsFixed(2)}",
            Icons.money_off,
            color: TColors.secondary),
      ],
    );
  }

  Widget _buildOrdersHeader(AdminDashboardLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${AppLocalizations.of(context)!.myOrders} (${state.orders.totalCount})",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: _showFilterBottomsheet),
            IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: _showDateFilterBottomsheet),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(TextEditingController controller,
      Function(String) onChanged, String hint) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextFormField(
          controller: controller,
          onChanged: onChanged, // live search (debounced in the handler)
          onFieldSubmitted: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
          ),
        );
      },
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
    final l10n = AppLocalizations.of(context)!;
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey.shade100,
                  child:
                  const Icon(Icons.fastfood_outlined, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    "${item.price.toStringAsFixed(2)} EGP • ${item.category}",
                    style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _buildStockBadge(item),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: TColors.primary, size: 20),
                  onPressed: () => _showAddEditItemSheet(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
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
    final l10n = AppLocalizations.of(context)!;
    final bool hasVariants = item.hasVariants == true;
    final String label =
    hasVariants ? l10n.inStock : "${l10n.quantity}: ${item.stock ?? 0}";
    final Color color =
    (hasVariants || (item.stock ?? 0) > 0) ? Colors.green : Colors.red;

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
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController stockController =
        TextEditingController(text: (item.stock ?? 0).toString());
    
    final Map<String, TextEditingController> variantControllers = {};
    if (item.hasVariants == true && item.variants != null) {
      for (var v in item.variants!) {
        variantControllers[v.name] =
            TextEditingController(text: (v.stock ?? 0).toString());
      }
    }

    final adminBloc = context.read<AdminBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${l10n.inStock}: ${item.name}",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              if (item.hasVariants == true && item.variants != null)
                ...item.variants!.map((v) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(v.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500))),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: variantControllers[v.name],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: l10n.inStock, isDense: true),
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
                  decoration: InputDecoration(
                      labelText: l10n.inStock,
                      border: const OutlineInputBorder()),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (item.hasVariants == true && item.variants != null) {
                      for (var v in item.variants!) {
                        final val = variantControllers[v.name]?.text ?? '0';
                        adminBloc.add(SetVariantStockEvent(
                          itemId: item.mongoId ?? item.id,
                          variantName: v.name,
                          stock: int.tryParse(val) ?? 0,
                        ));
                      }
                    } else {
                      adminBloc.add(SetItemStockEvent(
                        itemId: item.mongoId ?? item.id,
                        stock: int.tryParse(stockController.text) ?? 0,
                      ));
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary),
                  child: Text(l10n.save,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// The three fixed categories. Keys are the values stored in the DB; labels
  /// are localized. Cold Drink → 'cold', Hot Drinks → 'hot', Side Items → 'neutral'.
  String _normalizeCategory(String? raw) {
    if (raw == 'cold') return 'cold';
    if (raw == 'hot') return 'hot';
    return 'neutral';
  }

  void _showAddEditItemSheet([MenuItemEntity? item]) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: item?.name);
    final priceController =
    TextEditingController(text: item?.price.toString());
    String selectedCategory = _normalizeCategory(item?.category);
    final descController = TextEditingController(text: item?.description);
    final imageController = TextEditingController(text: item?.image);
    final stockController =
    TextEditingController(text: item?.stock?.toString() ?? "0");
    bool hasVariants = item?.hasVariants ?? false;
    bool hasSugar = item?.hasSugar ?? false;
    final adminBloc = context.read<AdminBloc>();
    final itemId = item == null ? null : (item.mongoId ?? item.id);

    // Variant rows are held in-memory for BOTH create and edit, and saved
    // together with the item on submit (create -> CreateMenuItem with variants,
    // edit -> UpdateMenuItem with the full variants array, which the backend
    // replaces). Seed existing variants when editing.
    final variantNameControllers = <TextEditingController>[];
    final variantStockControllers = <TextEditingController>[];
    if (item?.variants != null) {
      for (final v in item!.variants!) {
        variantNameControllers.add(TextEditingController(text: v.name));
        variantStockControllers
            .add(TextEditingController(text: (v.stock ?? 0).toString()));
      }
    }

    final categoryItems = [
      DropdownMenuItem(value: 'cold', child: Text(l10n.coldDrinks)),
      DropdownMenuItem(value: 'hot', child: Text(l10n.hotDrinks)),
      DropdownMenuItem(value: 'neutral', child: Text(l10n.sides)),
    ];

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
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item == null ? l10n.additemMenu: l10n.edit,
                        style: Theme.of(stfContext).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: l10n.itemName)),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration:
                        InputDecoration(labelText: l10n.price)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(labelText: l10n.category),
                      items: categoryItems,
                      onChanged: (val) => setState(
                          () => selectedCategory = val ?? 'neutral'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: descController,
                        decoration:
                        InputDecoration(labelText: l10n.specialInstructions)),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: imageController,
                        decoration:
                        InputDecoration(labelText: "Image URL")),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(l10n.varaity),
                      value: hasVariants,
                      onChanged: (val) => setState(() {
                        hasVariants = val;
                        if (hasVariants) {
                          ensureVariantRow();
                        } else {
                          variantNameControllers.clear();
                          variantStockControllers.clear();
                        }
                      }),
                    ),
                    SwitchListTile(
                      title: Text(l10n.sugarOption),
                      secondary: const Icon(Icons.water_drop_outlined),
                      value: hasSugar,
                      onChanged: (val) => setState(() => hasSugar = val),
                    ),
                    const SizedBox(height: 12),
                    // Simple stock field (create only — editing stock for an
                    // existing simple item is done in the stock/inventory tab),
                    // or the variant editor (create + edit).
                    if (!hasVariants)
                      (item == null)
                          ? TextFormField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.inStock,
                                border: const OutlineInputBorder(),
                              ),
                            )
                          : const SizedBox.shrink()
                    else ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(l10n.varaity,
                            style: Theme.of(stfContext).textTheme.titleMedium),
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
                                    labelText: l10n.variantName,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: variantStockControllers[i],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.inStock,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.remove,
                                onPressed: () => setState(() {
                                  variantNameControllers.removeAt(i);
                                  variantStockControllers.removeAt(i);
                                }),
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
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
                          label: Text(l10n.addVariant),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Collect non-empty variant rows.
                          final variants = hasVariants
                              ? List.generate(
                                  variantNameControllers.length,
                                  (i) => VariantEntity(
                                    name: variantNameControllers[i].text.trim(),
                                    stock: int.tryParse(
                                            variantStockControllers[i].text) ??
                                        0,
                                  ),
                                )
                                  .where((v) => v.name.isNotEmpty)
                                  .toList()
                              : <VariantEntity>[];

                          // A variant item must have at least one variant.
                          if (hasVariants && variants.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.varaityIsRequired)),
                            );
                            return;
                          }

                          if (item == null) {
                            adminBloc.add(CreateMenuItemEvent(
                              name: nameController.text,
                              price:
                              double.tryParse(priceController.text) ?? 0.0,
                              category: selectedCategory,
                              description: descController.text,
                              image: imageController.text,
                              hasVariants: hasVariants,
                              stock: hasVariants
                                  ? 0
                                  : (int.tryParse(stockController.text) ?? 0),
                              variants: hasVariants ? variants : null,
                              hasSugar: hasSugar,
                            ));
                          } else {
                            adminBloc.add(UpdateMenuItemEvent(
                              itemId: itemId!,
                              name: nameController.text,
                              price: double.tryParse(priceController.text),
                              category: selectedCategory,
                              description: descController.text,
                              image: imageController.text,
                              hasVariants: hasVariants,
                              // Replace the whole variants array on the server.
                              variants: hasVariants ? variants : <VariantEntity>[],
                              hasSugar: hasSugar,
                            ));
                          }
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary),
                        child: Text(
                            item == null ? l10n.additemMenu : l10n.edit,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text("${l10n.deleteAccountConfirm} ${item.name}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              context
                  .read<AdminBloc>()
                  .add(DeleteMenuItemEvent(item.mongoId ?? item.id));
              Navigator.pop(ctx);
            },
            child: Text(l10n.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      {Color color = Colors.black87}) {
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
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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

  /// Confirm then mark an order as paid (settles the customer's debt and
  /// realizes cafeteria revenue on the backend).
  /// Open the Pending Revenue (debt-by-user) screen with its own AdminBloc.
  void _openPendingRevenue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<AdminBloc>()..add(FetchPendingUsersEvent()),
          child: const PendingRevenuePage(),
        ),
      ),
    );
  }

  /// Two equal-width, side-by-side dialog buttons (Cancel + a colored confirm).
  Widget _dialogButtons(
    BuildContext dialogCtx, {
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(dialogCtx),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD9C7B8)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(l10n.cancel,
                  style: const TextStyle(color: Color(0xFF8B7355))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(confirmText,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmMarkPaid(OrderEntity order, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.markPaidConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.markPaidConfirmBody(
                order.totalPrice.toStringAsFixed(2),
                l10n.pound,
              ),
            ),
            const SizedBox(height: 24),
            _dialogButtons(
              ctx,
              confirmText: l10n.markAsPaid,
              confirmColor: Colors.green,
              onConfirm: () {
                Navigator.pop(ctx);
                context.read<AdminBloc>().add(
                      UpdateAdminOrderEvent(
                        orderId: order.id,
                        paymentStatus: 'paid',
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelOrder(OrderEntity order, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.cancelOrder),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.cancelOrderConfirm),
            const SizedBox(height: 24),
            _dialogButtons(
              ctx,
              confirmText: l10n.confirm,
              confirmColor: const Color(0xFFE57373),
              onConfirm: () {
                Navigator.pop(ctx);
                context.read<AdminBloc>().add(
                      UpdateAdminOrderEvent(
                        orderId: order.id,
                        status: 'cancelled',
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOrderCard(OrderEntity order) {
    final l10n = AppLocalizations.of(context)!;

    // ── Localized status label ──
    String _localizedStatus(String status) => switch (status) {
      'pending'    => l10n.orderConfirmed,
      'processing' => l10n.orderPreparing,
      'completed'  => l10n.orderReady,
      'delivered'  => l10n.orderDelivered,
      'cancelled'  => l10n.orderCancelled,
      _            => status.toUpperCase(),
    };

    // ── Action button config ──
    String adminActionText = '';
    Color adminActionColor = TColors.primary;
    VoidCallback? adminAction;

    if (order.status == 'pending') {
      adminActionText = l10n.orderPreparing;
      adminAction = () => context.read<AdminBloc>().add(
        UpdateAdminOrderEvent(orderId: order.id, status: 'processing'),
      );
    } else if (order.status == 'processing') {
      adminActionText = l10n.orderReady;
      adminActionColor = Colors.orange;
      adminAction = () => context.read<AdminBloc>().add(
        UpdateAdminOrderEvent(orderId: order.id, status: 'completed'),
      );
    } else if (order.status == 'completed') {
      adminActionText = l10n.orderDelivered;
      adminActionColor = Colors.orange.shade700;
      adminAction = () => context.read<AdminBloc>().add(
        UpdateAdminOrderEvent(orderId: order.id, status: 'delivered'),
      );
    } else if (order.paymentStatus == 'unpaid' &&
        order.status != 'cancelled') {
      // Settle a debt: mark an (often delivered) unpaid order as paid.
      adminActionText = l10n.markAsPaid;
      adminActionColor = Colors.green;
      adminAction = () => _confirmMarkPaid(order, l10n);
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
            // ── Top Row: ID + Status badges ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${order.id.substring(max(0, order.id.length - 8))}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _localizedStatus(order.status),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.paymentStatus == 'paid'
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.paymentStatus == 'paid'
                            ? l10n.paidOnly
                            : l10n.unpaidOnly,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Details ──
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  order.userName?.toUpperCase() ?? "UNKNOWN",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business_outlined,
                    size: 16, color: Colors.black),
                const SizedBox(width: 8),
                Text(order.deliveryLocation ?? l10n.address,
                    style: const TextStyle(color: Colors.black)),
              ],
            ),
            if (order.userPhone != null && order.userPhone!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone_outlined,
                      size: 16, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(order.userPhone!,
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_outlined,
                    size: 16, color: Colors.black),
                const SizedBox(width: 8),
                Text(DateFormat('hh:mm a').format(order.createdAt),
                    style: const TextStyle(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money_outlined,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "\$${order.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Order Items ──
            if (order.items.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(l10n.items,
                  style: const TextStyle(color: Colors.black, fontSize: 12)),
              const SizedBox(height: 8),
              ...order.items.map(
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
                              item.menuItemName ?? l10n.item,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                            if (item.variantName != null)
                              Text(
                                "${l10n.item}: ${item.variantName}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            if (item.sugar != null)
                              Text(
                                "${l10n.sugar}: ${l10n.sugarSpoons(item.sugar!)}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            Text(
                              "${l10n.quantity}: ${item.quantity}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black),
                            ),
                            if (item.note != null && item.note!.isNotEmpty)
                              Text(
                                "${l10n.specialInstructions}: ${item.note}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.orange),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        "\$${item.subtotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ── Action Button ──
            if (adminActionText.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: adminAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: adminActionColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(adminActionText,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],

            // ── Cancel Button ──
            if (order.status != 'cancelled' &&
                order.status != 'delivered') ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _confirmCancelOrder(order, l10n),
                  child: Text(l10n.cancelOrder,
                      style: const TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'pending'    => Colors.grey.shade800,
      'processing' => Colors.orange,
      'completed'  => Colors.green.shade400,
      'delivered'  => Colors.green,
      'cancelled'  => Colors.red,
      _            => Colors.grey,
    };
  }
}
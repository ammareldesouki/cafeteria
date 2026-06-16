import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/di/injaction.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../domain/entities/pending_user_entity.dart';
import '../../domain/use_cases/admin_usecases.dart';
import '../manager/admin_bloc.dart';
import '../manager/admin_event.dart';
import '../manager/admin_state.dart';

/// Lists every customer who owes money (delivered-unpaid debt) so staff can
/// record a payment — the full balance or a partial amount.
class PendingRevenuePage extends StatefulWidget {
  const PendingRevenuePage({super.key});

  @override
  State<PendingRevenuePage> createState() => _PendingRevenuePageState();
}

class _PendingRevenuePageState extends State<PendingRevenuePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PendingUserEntity> _filter(List<PendingUserEntity> users) {
    if (_query.isEmpty) return users;
    return users
        .where((u) => u.username.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF3B1A08),
        title: Text(
          l10n.pendingRevenueTitle,
          style: const TextStyle(
            color: Color(0xFF3B1A08),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is PendingUsersLoading || state is AdminInitial) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B1A08)),
              );
            }
            if (state is AdminError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<AdminBloc>()
                    .add(FetchPendingUsersEvent()),
              );
            }
            if (state is! PendingUsersLoaded) {
              return const SizedBox.shrink();
            }

            final result = state.result;
            final users = _filter(result.users);

            return RefreshIndicator(
              color: const Color(0xFF3B1A08),
              onRefresh: () async =>
                  context.read<AdminBloc>().add(FetchPendingUsersEvent()),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _searchBar(l10n),
                  const SizedBox(height: 16),
                  _totalCard(l10n, result),
                  const SizedBox(height: 16),
                  if (users.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          l10n.noPendingPayments,
                          style: const TextStyle(color: Color(0xFF8B7355)),
                        ),
                      ),
                    )
                  else
                    ...users.map((u) => _userCard(context, l10n, u)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _searchBar(AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
      decoration: InputDecoration(
        hintText: l10n.searchByUsername,
        prefixIcon: const Icon(Icons.search, color: Color(0xFF8B7355)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8D7BF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8D7BF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3B1A08), width: 1.4),
        ),
      ),
    );
  }

  Widget _totalCard(AppLocalizations l10n, PendingUsersResult result) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E9E2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3B1A08), width: 1.4),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFF3B1A08),
            child: Icon(Icons.attach_money, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalRevenue,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B1A08),
                  ),
                ),
                Text(
                  l10n.usersCount(result.userCount),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B7355),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${result.totalPending.toStringAsFixed(2)} ${l10n.pound}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0533D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(
    BuildContext context,
    AppLocalizations l10n,
    PendingUserEntity u,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8D7BF)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEDE7E0),
            child: const Icon(Icons.person, color: Color(0xFF8B7355)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B1A08),
                  ),
                ),
                Text(
                  l10n.unpaidOrdersCount(u.unpaidOrders),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B7355),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0533D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${u.pendingAmount.toStringAsFixed(2)} ${l10n.pound}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Plain tappable container (avoids ElevatedButton's tap-target
          // sizing, which can demand infinite width inside an RTL Row).
          GestureDetector(
            onTap: () => _showSettleDialog(context, l10n, u),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF5BA85B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.markPaid,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettleDialog(
    BuildContext pageContext,
    AppLocalizations l10n,
    PendingUserEntity u,
  ) {
    showDialog(
      context: pageContext,
      builder: (_) => _SettleOrdersDialog(
        user: u,
        onSettled: () =>
            pageContext.read<AdminBloc>().add(FetchPendingUsersEvent()),
      ),
    );
  }
}

/// Lists a user's delivered-but-unpaid orders with checkboxes (select all or a
/// subset) and marks the chosen ones paid — each PATCH flips the order's
/// paymentStatus to paid and settles the wallet on the backend.
class _SettleOrdersDialog extends StatefulWidget {
  final PendingUserEntity user;
  final VoidCallback onSettled;

  const _SettleOrdersDialog({required this.user, required this.onSettled});

  @override
  State<_SettleOrdersDialog> createState() => _SettleOrdersDialogState();
}

class _SettleOrdersDialogState extends State<_SettleOrdersDialog> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<OrderEntity> _orders = [];
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await sl<GetAdminOrdersUseCase>()(
        page: 1,
        limit: 100,
        userId: widget.user.userId,
        status: 'delivered',
        paymentStatus: 'unpaid',
      );
      if (!mounted) return;
      setState(() {
        _orders = res.data;
        _selected
          ..clear()
          ..addAll(_orders.map((o) => o.id)); // default: all selected
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  double get _selectedTotal => _orders
      .where((o) => _selected.contains(o.id))
      .fold(0.0, (s, o) => s + o.totalPrice);

  Future<void> _submit(AppLocalizations l10n) async {
    if (_selected.isEmpty) return;
    setState(() => _submitting = true);
    final update = sl<UpdateAdminOrderUseCase>();
    try {
      // Mark each selected order paid (flips status + settles wallet).
      for (final id in _selected.toList()) {
        await update(orderId: id, paymentStatus: 'paid');
      }
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSettled();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.markAsPaid)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allSelected =
        _orders.isNotEmpty && _selected.length == _orders.length;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      title: Text(widget.user.username),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B1A08)),
                ),
              )
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  )
                : _orders.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(l10n.noPendingPayments,
                            style: const TextStyle(color: Color(0xFF8B7355))),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Select all
                          CheckboxListTile(
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: const Color(0xFF5BA85B),
                            value: allSelected,
                            title: Text(l10n.payAll),
                            onChanged: (v) => setState(() {
                              _selected.clear();
                              if (v == true) {
                                _selected.addAll(_orders.map((o) => o.id));
                              }
                            }),
                          ),
                          const Divider(height: 1),
                          Flexible(
                            child: ListView(
                              shrinkWrap: true,
                              children: _orders.map((o) {
                                final shortId = o.id.length > 6
                                    ? o.id.substring(o.id.length - 6)
                                    : o.id;
                                final items = o.items
                                    .map((it) =>
                                        '${it.quantity}x ${it.menuItemName ?? l10n.item}')
                                    .join(', ');
                                return CheckboxListTile(
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  activeColor: const Color(0xFF5BA85B),
                                  value: _selected.contains(o.id),
                                  title: Text(
                                    '#$shortId • ${o.totalPrice.toStringAsFixed(2)} ${l10n.pound}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(items,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  onChanged: (v) => setState(() {
                                    if (v == true) {
                                      _selected.add(o.id);
                                    } else {
                                      _selected.remove(o.id);
                                    }
                                  }),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel,
              style: const TextStyle(color: Color(0xFF8B7355))),
        ),
        ElevatedButton(
          onPressed:
              (_submitting || _selected.isEmpty) ? null : () => _submit(l10n),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5BA85B),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  '${l10n.markPaid} (${_selectedTotal.toStringAsFixed(2)} ${l10n.pound})',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: Color(0xFF8B7355), size: 52),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8B7355))),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              AppLocalizations.of(context)!.tryAgain,
              style: const TextStyle(color: TColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

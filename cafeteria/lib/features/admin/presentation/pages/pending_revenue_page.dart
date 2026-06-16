import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/pending_user_entity.dart';
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B1A08),
                  ),
                ),
                Text(
                  l10n.unpaidOrdersCount(u.unpaidOrders),
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
          ElevatedButton(
            onPressed: () => _showSettleDialog(context, l10n, u),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5BA85B),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              l10n.markPaid,
              style: const TextStyle(color: Colors.white, fontSize: 13),
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
    final amountController = TextEditingController();
    String? errorText;

    showDialog(
      context: pageContext,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          void submit({required bool payAll}) {
            double? amount;
            if (!payAll) {
              final parsed = double.tryParse(amountController.text.trim());
              if (parsed == null || parsed <= 0) {
                setDialogState(() => errorText = l10n.enterAmount);
                return;
              }
              if (parsed > u.pendingAmount) {
                setDialogState(() => errorText = l10n.amountExceedsDebt);
                return;
              }
              amount = parsed;
            }
            Navigator.pop(ctx);
            pageContext.read<AdminBloc>().add(
                  SettleUserDebtEvent(userId: u.userId, amount: amount),
                );
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(l10n.settlePaymentTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${u.username} • ${u.pendingAmount.toStringAsFixed(2)} ${l10n.pound}',
                  style: const TextStyle(color: Color(0xFF8B7355)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) {
                    if (errorText != null) {
                      setDialogState(() => errorText = null);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.partialAmount,
                    hintText: l10n.enterAmount,
                    errorText: errorText,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side:
                                const BorderSide(color: Color(0xFFD9C7B8)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(l10n.cancel,
                              style:
                                  const TextStyle(color: Color(0xFF8B7355))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => submit(
                            payAll: amountController.text.trim().isEmpty,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5BA85B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            amountController.text.trim().isEmpty
                                ? l10n.payAll
                                : l10n.confirm,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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

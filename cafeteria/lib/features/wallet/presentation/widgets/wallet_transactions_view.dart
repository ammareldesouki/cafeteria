import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import '../manager/wallet_bloc.dart';
import '../manager/wallet_state.dart';

/// Transaction history list. Reads the [WalletBloc] provided by an ancestor
/// (so the same live `/me/wallet/details` fetch drives the balance too).
class WalletTransactionsView extends StatelessWidget {
  const WalletTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading || state is WalletInitial) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFF3B1A08)),
              ),
            );
          }

          if (state is WalletError) {
            return Center(
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            );
          }

          if (state is WalletLoaded) {
            final txns = state.details.transactions;
            if (txns.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.noRecentTransactions,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: txns.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Color(0xFFF1E9E1), height: 1),
              itemBuilder: (_, i) => _TransactionTile(txn: txns[i]),
            );
          }

          return const SizedBox.shrink();
        },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransactionEntity txn;

  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final bool isCredit = txn.isCredit;
    final Color color =
        isCredit ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final String sign = isCredit ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3B1A08),
                  ),
                ),
                if (txn.createdAt != null)
                  Text(
                    _formatDate(txn.createdAt!),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign${txn.amount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.pound}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }
}

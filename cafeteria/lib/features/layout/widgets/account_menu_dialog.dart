import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/local/locale_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/presentation/manager/auth_bloc.dart';
import '../../auth/presentation/widgets/language_theme_toggles.dart';

class AccountMenuDialog extends StatefulWidget {
  final UserEntity user;

  const AccountMenuDialog({super.key, required this.user});

  @override
  State<AccountMenuDialog> createState() => _AccountMenuDialogState();
}

class _AccountMenuDialogState extends State<AccountMenuDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Account Menu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B1A08),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const Divider(color: Color(0xFFE8D7BF)),
            const SizedBox(height: 10),
            _buildTabBar(),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAccountTab(),
                  _buildSettingsTab(),
                  _buildWalletTab(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorPadding: const EdgeInsets.all(4),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        unselectedLabelColor: Colors.grey,
        labelColor: const Color(0xFF8B7355),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'Account'),
          Tab(text: 'Settings'),
          Tab(text: 'Wallet'),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF9F5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8D7BF)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF3B1A08),
                  child: Text(
                    widget.user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B1A08),
                        ),
                      ),
                      Text(
                        widget.user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B7355),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D7BF).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.user.role.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Total Orders', widget.user.totalOrders.toString()),
          const SizedBox(height: 12),
          _buildStatCard('Completed Orders', widget.user.completedOrders.toString(), color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8B7355)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? const Color(0xFF3B1A08),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.translate_rounded, color: Color(0xFF8B7355)),
            title: Text(
              AppLocalizations.of(context)!.language,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            trailing: const LanguageThemeToggles(key: ValueKey('dialog_toggles')),
          ),
          const Divider(color: Color(0xFFFDF9F5)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.palette_outlined, color: Color(0xFF8B7355)),
            title: const Text(
              'App Appearance',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Light / Dark Mode', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTab() {
    final bool isNegative = widget.user.balance < 0;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF3B1A08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Wallet Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.user.balance.toStringAsFixed(2)} L.E',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isNegative)
                const Text(
                  'Negative Credit',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Recent Balance Updates',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3B1A08)),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text('No recent transactions', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<AuthBloc>().add(const SignOutEvent());

        },
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

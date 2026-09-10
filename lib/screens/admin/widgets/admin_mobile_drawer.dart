import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/user_model.dart';

class AdminMobileDrawer extends StatelessWidget {
  final TabController tabController;
  final bool isSuperAdmin;
  final AppUser? currentUser;
  final VoidCallback? onTabSelected;

  const AdminMobileDrawer({
    super.key,
    required this.tabController,
    required this.isSuperAdmin,
    required this.currentUser,
    this.onTabSelected,
  });

  Widget _buildMobileDrawerItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = tabController.index == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: const Color(0xFFEFF6FF),
      leading: Icon(
        icon,
        color:
            isSelected ? const Color(0xFF24487A) : const Color(0xFF64748B),
      ),
      title: Text(
        label,
        style: TextStyle(
          color:
              isSelected ? const Color(0xFF1E40AF) : const Color(0xFF1E293B),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: () {
        tabController.animateTo(index);
        Navigator.pop(context);
        onTabSelected?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <(int, IconData, String)>[
      (0, Icons.grid_view_rounded, 'Dashboard'),
      (1, Icons.description_rounded, 'Berkas Loan'),
      (2, Icons.calendar_month_rounded, 'Jadwal Kalender'),
      if (isSuperAdmin) (3, Icons.directions_car_rounded, 'Katalog Armada'),
      if (isSuperAdmin) (4, Icons.manage_accounts_rounded, 'Kelola Admin'),
      (isSuperAdmin ? 5 : 3, Icons.people_alt_rounded, 'Daftar Pegawai'),
      if (isSuperAdmin) (6, Icons.bar_chart_rounded, 'Laporan'),
    ];

    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 12, 24),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo_sipk.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'SIP-K DINSOS',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup menu',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            for (final item in items)
              _buildMobileDrawerItem(context, item.$1, item.$2, item.$3),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isSuperAdmin ? const Color(0xFFFBBF24) : Colors.white,
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      currentUser?.name ?? 'Administrator',
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

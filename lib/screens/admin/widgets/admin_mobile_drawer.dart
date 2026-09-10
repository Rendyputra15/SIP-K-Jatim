import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/services/theme_service.dart';
import 'package:simodis_jatim/widgets/day_night_switch.dart';

class AdminMobileDrawer extends StatelessWidget {
  final TabController tabController;
  final bool isSuperAdmin;
  final AppUser? currentUser;
  final VoidCallback? onTabSelected;
  final VoidCallback? onLogout;

  const AdminMobileDrawer({
    super.key,
    required this.tabController,
    required this.isSuperAdmin,
    required this.currentUser,
    this.onTabSelected,
    this.onLogout,
  });

  Widget _buildMobileDrawerItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    bool isDark,
  ) {
    final isSelected = tabController.index == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor:
          isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
      leading: Icon(
        icon,
        color: isSelected
            ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A))
            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF1E40AF))
              : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
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
    final isDark = ThemeService.isDarkMode;
    final items = <(int, IconData, String)>[
      (0, Icons.grid_view_rounded, 'Dashboard'),
      (1, Icons.description_rounded, 'Berkas Loan'),
      (2, Icons.calendar_month_rounded, 'Jadwal Kalender'),
      if (isSuperAdmin) (3, Icons.directions_car_rounded, 'Katalog Armada'),
      if (isSuperAdmin) (4, Icons.manage_accounts_rounded, 'Kelola Admin'),
      (isSuperAdmin ? 5 : 3, Icons.people_alt_rounded, 'Kelola Pegawai'),
      if (isSuperAdmin) (6, Icons.bar_chart_rounded, 'Laporan'),
    ];

    return SafeArea(
      child: Container(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                  Expanded(
                    child: Text(
                      'SIP-K DINSOS',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup menu',
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 8),

            // Switch Mode Terang / Gelap (Di atas Dashboard)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          size: 18,
                          color: isDark
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDark ? 'Mode Gelap' : 'Mode Terang',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const DayNightSwitch(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            for (final item in items)
              _buildMobileDrawerItem(
                context,
                item.$1,
                item.$2,
                item.$3,
                isDark,
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onLogout?.call();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: isSuperAdmin
                              ? (isDark
                                  ? const Color(0xFF78350F)
                                  : const Color(0xFFFEF3C7))
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: isSuperAdmin
                                ? (isDark
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFFD97706))
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentUser?.name ?? 'Administrator',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isSuperAdmin
                                    ? 'Superadmin • Ketuk Logout'
                                    : 'Admin • Ketuk Logout',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: isDark
                              ? const Color(0xFFF87171)
                              : const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

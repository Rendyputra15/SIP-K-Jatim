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
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
      selected: isSelected,
      selectedTileColor:
          isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
      leading: Icon(
        icon,
        size: 19,
        color: isSelected
            ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A))
            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF1E40AF))
              : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
      (isSuperAdmin ? 7 : 4, Icons.insights_rounded, 'Performa'),
    ];

    return SafeArea(
      child: Container(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Logo, Nama, dan Tombol Tutup
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo_sipk.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SIP-K DINSOS',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.8,
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
            const SizedBox(height: 6),

            // Daftar Menu yang Aman dari Overflow (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Switch Mode Terang / Gelap
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
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
                                  size: 16,
                                  color: isDark
                                      ? const Color(0xFFFBBF24)
                                      : const Color(0xFFD97706),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isDark ? 'Mode Gelap' : 'Mode Terang',
                                  style: TextStyle(
                                    fontSize: 11.5,
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
                    const SizedBox(height: 4),

                    // Menu-menu Superadmin
                    for (final item in items)
                      _buildMobileDrawerItem(
                        context,
                        item.$1,
                        item.$2,
                        item.$3,
                        isDark,
                      ),
                  ],
                ),
              ),
            ),

            // Profile Card User di Bagian Bawah
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
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
                      vertical: 9,
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
                          radius: 15,
                          backgroundColor: isSuperAdmin
                              ? (isDark
                                  ? const Color(0xFF78350F)
                                  : const Color(0xFFFEF3C7))
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: isSuperAdmin
                                ? (isDark
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFFD97706))
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B)),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                                  fontSize: 11.5,
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
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.logout_rounded,
                          size: 16,
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

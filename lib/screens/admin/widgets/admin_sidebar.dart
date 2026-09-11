import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/services/theme_service.dart';
import 'package:simodis_jatim/widgets/day_night_switch.dart';

class AdminSidebar extends StatelessWidget {
  final TabController tabController;
  final bool isSuperAdmin;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final AppUser? currentUser;
  final Function(int) onTabSelected;
  final VoidCallback? onLogout;

  const AdminSidebar({
    super.key,
    required this.tabController,
    required this.isSuperAdmin,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.currentUser,
    required this.onTabSelected,
    this.onLogout,
  });

  Widget _buildSidebarItem(
    int index,
    IconData icon,
    String label,
    bool isDark,
  ) {
    final isSelected = tabController.index == index;
    final activeBg =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final indicatorColor =
        isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E293B);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final iconColor = isSelected
        ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E293B))
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return InkWell(
      onTap: () => onTabSelected(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          border: isSelected
              ? Border(
                  left: BorderSide(
                    color: indicatorColor,
                    width: 3.5,
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment:
              isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final headerTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final hamburgerColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final toggleBtnBg =
        isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final profileCardBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final profileNameColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final profileRoleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E293B);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExpanded ? 215 : 70,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header Sidebar: Logo, Ikon & Tombol Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: isExpanded
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  if (isExpanded)
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo_sipk.png',
                            width: 26,
                            height: 26,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'SIP-K DINSOS',
                              style: TextStyle(
                                color: headerTextColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isExpanded) const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onToggleExpand,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: toggleBtnBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.menu_open_rounded
                            : Icons.menu_rounded,
                        color: hamburgerColor,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Switch Mode Terang / Gelap (Di atas Dashboard)
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
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
                            isDark ? 'Gelap' : 'Terang',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const DayNightSwitch(),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Tooltip(
                  message:
                      isDark ? 'Ganti ke Mode Terang' : 'Ganti ke Mode Gelap',
                  child: InkWell(
                    onTap: () => ThemeService.toggleTheme(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        size: 18,
                        color: isDark
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ),
              ),

            // Menu Items
            _buildSidebarItem(0, Icons.grid_view_rounded, 'Dashboard', isDark),
            _buildSidebarItem(1, Icons.description_rounded, 'Berkas Loan', isDark),
            _buildSidebarItem(
              2,
              Icons.calendar_month_rounded,
              'Jadwal Kalender',
              isDark,
            ),
            if (isSuperAdmin)
              _buildSidebarItem(
                3,
                Icons.directions_car_rounded,
                'Katalog Armada',
                isDark,
              ),
            if (isSuperAdmin)
              _buildSidebarItem(
                4,
                Icons.manage_accounts_rounded,
                'Kelola Admin',
                isDark,
              ),
            _buildSidebarItem(
              isSuperAdmin ? 5 : 3,
              Icons.people_alt_rounded,
              'Kelola Pegawai',
              isDark,
            ),
            if (isSuperAdmin)
              _buildSidebarItem(
                6,
                Icons.bar_chart_rounded,
                'Laporan',
                isDark,
              ),
            _buildSidebarItem(
              isSuperAdmin ? 7 : 4,
              Icons.insights_rounded,
              'Performa',
              isDark,
            ),

            const Spacer(),
            // User Profile Mini (Klik untuk logout)
            Tooltip(
              message: 'Profil & Logout (${currentUser?.name ?? "Admin"})',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onLogout,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: isExpanded ? 12 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: profileCardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 14,
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
                        if (isExpanded) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentUser?.name.split(' ')[0] ??
                                      'Administrator',
                                  style: TextStyle(
                                    color: profileNameColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isSuperAdmin
                                      ? 'Superadmin'
                                      : 'Administrator',
                                  style: TextStyle(
                                    color: profileRoleColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
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

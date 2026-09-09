import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/user_model.dart';

class AdminSidebar extends StatelessWidget {
  final TabController tabController;
  final bool isSuperAdmin;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final AppUser? currentUser;
  final Function(int) onTabSelected;

  const AdminSidebar({
    super.key,
    required this.tabController,
    required this.isSuperAdmin,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.currentUser,
    required this.onTabSelected,
  });

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    final isSelected = tabController.index == index;
    return InkWell(
      onTap: () => onTabSelected(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment:
              isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? (isSuperAdmin ? const Color(0xFFFBBF24) : Colors.white)
                      : Colors.white.withValues(alpha: 0.4),
              size: 20,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExpanded ? 200 : 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isSuperAdmin
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFF24487A), const Color(0xFF1E3A8A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header Sidebar: Ikon & Tombol Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment:
                    isExpanded
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                children: [
                  if (isExpanded)
                    const Text(
                      'SIP-K DINSOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  GestureDetector(
                    onTap: onToggleExpand,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.menu_open_rounded
                            : Icons.menu_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Menu Items
            _buildSidebarItem(0, Icons.grid_view_rounded, 'Dashboard'),
            _buildSidebarItem(1, Icons.description_rounded, 'Berkas Loan'),
            if (isSuperAdmin)
              _buildSidebarItem(
                2,
                Icons.directions_car_rounded,
                'Katalog Armada',
              ),
            if (isSuperAdmin)
              _buildSidebarItem(
                3,
                Icons.manage_accounts_rounded,
                'Kelola Admin',
              ),
            _buildSidebarItem(
              isSuperAdmin ? 4 : 2,
              Icons.people_alt_rounded,
              'Daftar Pegawai',
            ),

            const Spacer(),
            // User Profile Mini
            Container(
              margin: const EdgeInsets.all(12),
              padding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: isExpanded ? 12 : 0,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        isSuperAdmin ? const Color(0xFFFBBF24) : Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color:
                          isSuperAdmin
                              ? Colors.black
                              : const Color(0xFF24487A),
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
                            currentUser?.name.split(' ')[0] ?? 'Admin',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isSuperAdmin ? 'Superadmin' : 'Kasubag',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

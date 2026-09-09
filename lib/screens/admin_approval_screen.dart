import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_dashboard_tab.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_loans_tab.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_users_tab.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_vehicles_tab.dart';
import 'package:simodis_jatim/screens/admin/widgets/admin_mobile_drawer.dart';
import 'package:simodis_jatim/screens/admin/widgets/admin_sidebar.dart';

class AdminApprovalScreen extends StatefulWidget {
  final List<LoanRequest> requests;
  final Function(LoanRequest, bool) onVerify;
  final Function(LoanRequest, int, String, String) onReturn;
  final AppUser? currentUser;
  final List<AppUser>? users;
  final Function(AppUser)? onAddUser;
  final Function(AppUser)? onUpdateUser;
  final Function(String)? onDeleteUser;

  final List<Vehicle>? vehicles;
  final Function(Vehicle)? onAddVehicle;
  final Function(Vehicle)? onUpdateVehicle;
  final Function(String)? onDeleteVehicle;

  const AdminApprovalScreen({
    super.key,
    required this.requests,
    required this.onVerify,
    required this.onReturn,
    this.currentUser,
    this.users,
    this.onAddUser,
    this.onUpdateUser,
    this.onDeleteUser,
    this.vehicles,
    this.onAddVehicle,
    this.onUpdateVehicle,
    this.onDeleteVehicle,
  });

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  bool _isSidebarExpanded = true;

  bool get _isSuperAdmin => widget.currentUser?.isSuperAdmin ?? false;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(
      length: _isSuperAdmin ? 5 : 3,
      vsync: this,
    );
    _mainTabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final pendingCount =
        widget.requests
            .where(
              (r) =>
                  r.status == LoanStatus.menunggu ||
                  r.status == LoanStatus.pending,
            )
            .length;
    final activeCount =
        widget.requests
            .where(
              (r) =>
                  r.status == LoanStatus.disetujui ||
                  r.status == LoanStatus.approved,
            )
            .length;
    final completedCount =
        widget.requests
            .where(
              (r) =>
                  r.status == LoanStatus.selesai ||
                  r.status == LoanStatus.ditolak ||
                  r.status == LoanStatus.rejected,
            )
            .length;

    final allVehicles = widget.vehicles ?? [];
    final allUsers = widget.users ?? [];
    final adminList = allUsers.where((u) => u.isAdmin).toList();
    final userList =
        allUsers.where((u) => !u.isSuperAdmin && !u.isAdmin).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer:
          isMobile
              ? Drawer(
                child: AdminMobileDrawer(
                  tabController: _mainTabController,
                  isSuperAdmin: _isSuperAdmin,
                  currentUser: widget.currentUser,
                  onTabSelected: () => setState(() {}),
                ),
              )
              : null,
      body: Row(
        children: [
          // 1. SIDEBAR (DESKTOP)
          if (!isMobile)
            AdminSidebar(
              tabController: _mainTabController,
              isSuperAdmin: _isSuperAdmin,
              isExpanded: _isSidebarExpanded,
              onToggleExpand:
                  () => setState(
                    () => _isSidebarExpanded = !_isSidebarExpanded,
                  ),
              currentUser: widget.currentUser,
              onTabSelected: (index) {
                _mainTabController.animateTo(index);
                setState(() {});
              },
            ),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // Header Banner
                Container(
                  padding: EdgeInsets.fromLTRB(isMobile ? 8 : 20, 16, 20, 16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      if (isMobile)
                        Builder(
                          builder:
                              (context) => IconButton(
                                tooltip: 'Buka menu',
                                onPressed:
                                    () => Scaffold.of(context).openDrawer(),
                                icon: const Icon(Icons.menu_rounded),
                                color: const Color(0xFF24487A),
                              ),
                        )
                      else if (!_isSidebarExpanded) ...[
                        const Text(
                          'SIP-K',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF24487A),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          height: 24,
                          child: VerticalDivider(
                            width: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isSuperAdmin
                                  ? 'SISTEM INFORMASI KENDARAAN (SUPER)'
                                  : 'MANAJEMEN ARMADA DINSOS',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Text(
                              'UPT Dinas Sosial Provinsi Jawa Timur',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF64748B),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Content Switcher
                Expanded(
                  child: TabBarView(
                    controller: _mainTabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      AdminDashboardTab(
                        pendingCount: pendingCount,
                        activeCount: activeCount,
                        completedCount: completedCount,
                        totalVehicles: allVehicles.length,
                      ),
                      AdminLoansTab(
                        requests: widget.requests,
                        onVerify: widget.onVerify,
                        onReturn: widget.onReturn,
                      ),
                      if (_isSuperAdmin)
                        AdminVehiclesTab(
                          vehicles: allVehicles,
                          onAddVehicle: widget.onAddVehicle,
                          onUpdateVehicle: widget.onUpdateVehicle,
                          onDeleteVehicle: widget.onDeleteVehicle,
                        ),
                      if (_isSuperAdmin)
                        AdminUsersTab(
                          targetRole: UserRole.admin,
                          title: 'Daftar Admin (Kasubag & Tim Aset)',
                          subtitle: 'Akun pengelola verifikasi armada.',
                          userList: adminList,
                          isSuperAdmin: _isSuperAdmin,
                          onAddUser: widget.onAddUser,
                          onUpdateUser: widget.onUpdateUser,
                          onDeleteUser: widget.onDeleteUser,
                        ),
                      AdminUsersTab(
                        targetRole: UserRole.user,
                        title: 'Daftar Pegawai (User Pemohon)',
                        subtitle: 'Akun pegawai yang berhak mengajukan.',
                        userList: userList,
                        isSuperAdmin: _isSuperAdmin,
                        onAddUser: widget.onAddUser,
                        onUpdateUser: widget.onUpdateUser,
                        onDeleteUser: widget.onDeleteUser,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

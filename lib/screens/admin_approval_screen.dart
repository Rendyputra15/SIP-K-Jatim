import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/notification_model.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_calendar_tab.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_dashboard_tab.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_loans_tab.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_performance_tab.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_reports_tab.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_users_tab.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_vehicles_tab.dart';
import 'package:simodis_jatim/screens/admin/widgets/admin_mobile_drawer.dart';
import 'package:simodis_jatim/screens/admin/widgets/admin_sidebar.dart';
import 'package:simodis_jatim/screens/login_screen.dart';
import 'package:simodis_jatim/screens/notification_screen.dart';
import 'package:simodis_jatim/services/theme_service.dart';

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

  final List<AppNotification>? notifications;
  final VoidCallback? onLogout;

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
    this.notifications,
    this.onLogout,
  });

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  bool _isSidebarExpanded = true;
  late List<AppNotification> _notifications;
  final LayerLink _notifLayerLink = LayerLink();
  OverlayEntry? _notifOverlayEntry;

  bool get _isSuperAdmin => widget.currentUser?.isSuperAdmin ?? false;
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(
      length: _isSuperAdmin ? 8 : 5,
      vsync: this,
    );
    _mainTabController.addListener(() {
      if (mounted) setState(() {});
    });

    _notifications = widget.notifications != null
        ? List.from(widget.notifications!)
        : [
            AppNotification(
              id: 'ADM-001',
              title: 'Permohonan Masuk: Perlu Verifikasi',
              message:
                  'Rendy Cahyono (Subbag Program) mengajukan Toyota Innova Reborn untuk Monev UPT Balai Malang.',
              time: '10 mnt lalu',
              fullDate: '10 September 2026, 11:30 WIB',
              detailContent:
                  'Permohonan dinas masuk ke antrean verifikasi Kasubag. Tanggal tugas 12-14 September 2026. Dokumen Nota Dinas dan formulir permohonan telah dilampirkan.',
              referenceNumber: 'REQ-2026-0910-01',
              createdAt:
                  DateTime.now().subtract(const Duration(minutes: 10)),
              type: NotificationType.submitted,
              isRead: false,
            ),
            AppNotification(
              id: 'ADM-002',
              title: 'Peringatan Servis Rutin Armada',
              message:
                  'Toyota Avanza 1.3 Veloz (L 1455 EP) telah mencapai 49.850 KM. Segera jadwalkan ganti oli berkala.',
              time: '45 mnt lalu',
              fullDate: '10 September 2026, 10:45 WIB',
              detailContent:
                  'Sistem telematika mendeteksi odometer armada mendekati ambang batas servis 50.000 KM. Hubungi bengkel rekanan Pemprov Jatim untuk perawatan berkala.',
              referenceNumber: 'SRV-2026-09-002',
              createdAt:
                  DateTime.now().subtract(const Duration(minutes: 45)),
              type: NotificationType.maintenance,
              isRead: false,
            ),
            AppNotification(
              id: 'ADM-003',
              title: 'Pengembalian Unit & BAST Masuk',
              message:
                  'Bambang Triyono telah menyelesaikan perjalanan dinas dengan Isuzu Elf Minibus. Menunggu cek fisik & BAST.',
              time: '2 jam lalu',
              fullDate: '10 September 2026, 09:15 WIB',
              detailContent:
                  'Unit telah diparkir di Pool Dinsos Jatim. Pengemudi melaporkan BBM 3/4 tangki, odometer akhir 45.200 KM, dan melampirkan formulir BAST serah terima kunci.',
              referenceNumber: 'BAST-2026-0902',
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
              type: NotificationType.approved,
              isRead: false,
            ),
            AppNotification(
              id: 'ADM-004',
              title: 'Peringatan: Jadwal Penugasan Bentrok',
              message:
                  'Terdapat 2 usulan penugasan bersamaan pada tanggal 15 September untuk unit Toyota HiAce Commuter.',
              time: 'Kemarin',
              fullDate: '09 September 2026, 16:30 WIB',
              detailContent:
                  'Bidang Linjamsos dan Bidang Rehsos mengajukan unit yang sama pada tanggal 15-16 September 2026. Mohon Kasubag melakukan penyesuaian alokasi armada alternatif.',
              referenceNumber: 'WARN-SCH-004',
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
              type: NotificationType.reminder,
              isRead: true,
            ),
            AppNotification(
              id: 'ADM-005',
              title: 'Pendaftaran Akun Pegawai Baru',
              message:
                  'Siti Nurhaliza, S.Tr.Sos (Bidang Rehsos) mendaftarkan akun baru SIP-K.',
              time: '2 hari lalu',
              fullDate: '08 September 2026, 14:00 WIB',
              detailContent:
                  'Data pegawai NIP 199806122022032005 telah diverifikasi oleh kepegawaian. Silakan periksa di menu Kelola Pegawai untuk aktivasi hak akses.',
              referenceNumber: 'USR-REG-2026-088',
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
              type: NotificationType.welcome,
              isRead: true,
            ),
            AppNotification(
              id: 'ADM-006',
              title: 'Rekapitulasi Bulanan Siap Ekspor',
              message:
                  'Laporan pemakaian dan utilisasi armada dinas periode Agustus 2026 telah rampung.',
              time: '3 hari lalu',
              fullDate: '07 September 2026, 08:00 WIB',
              detailContent:
                  'Data rekapitulasi 42 berkas peminjaman bulan Agustus telah siap diunduh dalam format PDF/Excel pada tab Laporan.',
              referenceNumber: 'REP-2026-08-01',
              createdAt: DateTime.now().subtract(const Duration(days: 3)),
              type: NotificationType.approved,
              isRead: true,
            ),
          ];
  }

  @override
  void dispose() {
    _hideNotificationPopup();
    _mainTabController.dispose();
    super.dispose();
  }

  void _toggleNotificationPopup() {
    if (_notifOverlayEntry != null) {
      _hideNotificationPopup();
    } else {
      _showNotificationPopup();
    }
  }

  void _showNotificationPopup() {
    _hideNotificationPopup();
    _notifOverlayEntry = _createNotificationOverlay();
    Overlay.of(context).insert(_notifOverlayEntry!);
    if (mounted) setState(() {});
  }

  void _hideNotificationPopup() {
    if (_notifOverlayEntry != null) {
      _notifOverlayEntry?.remove();
      _notifOverlayEntry = null;
      if (mounted) setState(() {});
    }
  }

  OverlayEntry _createNotificationOverlay() {
    return OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isMobile = screenWidth < 700;
        final popupWidth = isMobile
            ? (screenWidth - 24).clamp(200.0, 340.0)
            : 340.0;

        return Stack(
          children: [
            // Backdrop transparan untuk mendeteksi klik di luar popup
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideNotificationPopup,
                child: const SizedBox.expand(),
              ),
            ),
            // Popup yang ditempatkan tepat di bawah logo notifikasi
            if (isMobile)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 64,
                right: 12,
                width: popupWidth,
                child: _buildNotificationPopupCard(),
              )
            else
              Positioned(
                width: popupWidth,
                child: CompositedTransformFollower(
                  link: _notifLayerLink,
                  showWhenUnlinked: false,
                  targetAnchor: Alignment.bottomRight,
                  followerAnchor: Alignment.topRight,
                  offset: const Offset(0, 8),
                  child: _buildNotificationPopupCard(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationPopupCard() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Material(
          elevation: 16,
          shadowColor: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 460),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Popup
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _isSuperAdmin
                              ? (isDark
                                  ? const Color(0xFF78350F).withOpacity(0.5)
                                  : const Color(0xFFFEF3C7))
                              : (isDark
                                  ? const Color(0xFF1E3A8A).withOpacity(0.5)
                                  : const Color(0xFFEFF6FF)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _unreadCount > 0
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          size: 16,
                          color: _isSuperAdmin
                              ? const Color(0xFFD97706)
                              : const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isSuperAdmin
                                  ? 'Notifikasi Superadmin'
                                  : 'Notifikasi Admin',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              _unreadCount > 0
                                  ? '$_unreadCount permohonan & agenda baru'
                                  : 'Semua informasi operasional terkini',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_unreadCount > 0)
                        InkWell(
                          onTap: () {
                            setState(() {
                              for (var n in _notifications) {
                                n.isRead = true;
                              }
                            });
                            _notifOverlayEntry?.markNeedsBuild();
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              'Tandai Dibaca',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isSuperAdmin
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                ),

                // Daftar Item Notifikasi
                Flexible(
                  child: _notifications.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 36,
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tidak ada notifikasi admin saat ini',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _notifications.take(5).length,
                          separatorBuilder: (_, index) => Divider(
                            height: 1,
                            thickness: 0.8,
                            color: isDark
                                ? const Color(0xFF334155).withOpacity(0.5)
                                : const Color(0xFFF1F5F9),
                          ),
                          itemBuilder: (context, index) {
                            final notif = _notifications[index];
                            return _buildNotificationPopupItem(notif, isDark);
                          },
                        ),
                ),

                // Footer Popup
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                ),
                InkWell(
                  onTap: () {
                    _hideNotificationPopup();
                    _openNotifications();
                  },
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Buka Riwayat Lengkap',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isSuperAdmin
                                ? const Color(0xFFD97706)
                                : const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: _isSuperAdmin
                              ? const Color(0xFFD97706)
                              : const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationPopupItem(AppNotification notif, bool isDark) {
    Color iconColor;
    Color iconBg;
    IconData iconData;

    switch (notif.type) {
      case NotificationType.submitted:
        iconColor = const Color(0xFF2563EB);
        iconBg = isDark
            ? const Color(0xFF1E3A8A).withOpacity(0.3)
            : const Color(0xFFEFF6FF);
        iconData = Icons.assignment_outlined;
        break;
      case NotificationType.maintenance:
        iconColor = const Color(0xFFD97706);
        iconBg = isDark
            ? const Color(0xFF78350F).withOpacity(0.3)
            : const Color(0xFFFEF3C7);
        iconData = Icons.build_circle_outlined;
        break;
      case NotificationType.approved:
        iconColor = const Color(0xFF16A34A);
        iconBg = isDark
            ? const Color(0xFF14532D).withOpacity(0.3)
            : const Color(0xFFDCFCE7);
        iconData = Icons.assignment_turned_in_outlined;
        break;
      case NotificationType.rejected:
        iconColor = const Color(0xFFDC2626);
        iconBg = isDark
            ? const Color(0xFF7F1D1D).withOpacity(0.3)
            : const Color(0xFFFEE2E2);
        iconData = Icons.cancel_outlined;
        break;
      case NotificationType.reminder:
        iconColor = const Color(0xFFEA580C);
        iconBg = isDark
            ? const Color(0xFF7C2D12).withOpacity(0.3)
            : const Color(0xFFFFEDD5);
        iconData = Icons.warning_amber_rounded;
        break;
      case NotificationType.welcome:
        iconColor = const Color(0xFF6366F1);
        iconBg = isDark
            ? const Color(0xFF312E81).withOpacity(0.3)
            : const Color(0xFFEEF2FF);
        iconData = Icons.person_add_alt_1_outlined;
        break;
    }

    return InkWell(
      onTap: () {
        setState(() {
          notif.isRead = true;
        });
        _hideNotificationPopup();

        // Navigasi ke tab relevan jika ada
        if (notif.type == NotificationType.submitted) {
          _mainTabController.animateTo(1); // Berkas Loan
        } else if (notif.type == NotificationType.maintenance) {
          if (_isSuperAdmin) _mainTabController.animateTo(3); // Katalog Armada
        } else if (notif.type == NotificationType.welcome) {
          if (_isSuperAdmin) {
            _mainTabController.animateTo(5); // Kelola Pegawai
          } else {
            _mainTabController.animateTo(3); // Kelola Pegawai
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: !notif.isRead
            ? (_isSuperAdmin
                ? (isDark
                    ? const Color(0xFF78350F).withOpacity(0.12)
                    : const Color(0xFFFFFBEB))
                : (isDark
                    ? const Color(0xFF1E3A8A).withOpacity(0.12)
                    : const Color(0xFFF0F9FF)))
            : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: notif.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notif.isRead) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
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

  void _openNotifications() {
    _hideNotificationPopup();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationScreen(
          notifications: _notifications,
          onClearAll: () {
            setState(() {
              _notifications.clear();
            });
          },
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showLogoutDialog() {
    _hideNotificationPopup();
    final isDark = ThemeService.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: _isSuperAdmin
                    ? (isDark
                        ? const Color(0xFF78350F)
                        : const Color(0xFFFEF3C7))
                    : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: _isSuperAdmin
                      ? (isDark
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFD97706))
                      : (isDark
                          ? Colors.white
                          : const Color(0xFF1E293B)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.currentUser?.name ?? 'Administrator SIP-K',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isSuperAdmin
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isSuperAdmin
                      ? 'Superadmin (Akses Penuh)'
                      : 'Kasubag / Admin TU & Aset',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _isSuperAdmin
                        ? const Color(0xFFB45309)
                        : const Color(0xFF1E40AF),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Apakah Anda yakin ingin keluar dari sesi akun ini?',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (widget.onLogout != null) {
                          widget.onLogout!();
                        } else {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout_rounded, size: 15),
                          SizedBox(width: 4),
                          Text(
                            'Logout',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        final isMobile = MediaQuery.sizeOf(context).width < 700;
        final pendingCount = widget.requests
            .where(
              (r) =>
                  r.status == LoanStatus.menunggu ||
                  r.status == LoanStatus.pending,
            )
            .length;
        final activeCount = widget.requests
            .where(
              (r) =>
                  r.status == LoanStatus.disetujui ||
                  r.status == LoanStatus.approved,
            )
            .length;
        final completedCount = widget.requests
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
          backgroundColor:
              isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          drawer: isMobile
              ? Drawer(
                  child: AdminMobileDrawer(
                    tabController: _mainTabController,
                    isSuperAdmin: _isSuperAdmin,
                    currentUser: widget.currentUser,
                    onTabSelected: () => setState(() {}),
                    onLogout: _showLogoutDialog,
                  ),
                )
              : null,
          body: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // 1. SIDEBAR (DESKTOP)
                if (!isMobile)
                  AdminSidebar(
                    tabController: _mainTabController,
                    isSuperAdmin: _isSuperAdmin,
                    isExpanded: _isSidebarExpanded,
                    onToggleExpand: () => setState(
                      () => _isSidebarExpanded = !_isSidebarExpanded,
                    ),
                    currentUser: widget.currentUser,
                    onLogout: _showLogoutDialog,
                    onTabSelected: (index) {
                      _hideNotificationPopup();
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
                        padding:
                            EdgeInsets.fromLTRB(isMobile ? 8 : 20, 12, 14, 12),
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        child: Row(
                          children: [
                            if (isMobile)
                              Builder(
                                builder: (context) => IconButton(
                                  tooltip: 'Buka menu',
                                  onPressed: () {
                                    _hideNotificationPopup();
                                    Scaffold.of(context).openDrawer();
                                  },
                                  icon: Icon(
                                    Icons.menu_rounded,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF24487A),
                                  ),
                                ),
                              )
                            else if (!_isSidebarExpanded) ...[
                              Text(
                                'SIP-K',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF24487A),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                height: 24,
                                child: VerticalDivider(
                                  width: 1,
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isSuperAdmin
                                        ? (isMobile
                                            ? 'SIP-K SUPERADMIN'
                                            : 'SISTEM INFORMASI KENDARAAN (SUPER)')
                                        : (isMobile
                                            ? 'SIP-K ARMADA DINSOS'
                                            : 'MANAJEMEN ARMADA DINSOS'),
                                    style: TextStyle(
                                      fontSize: isMobile ? 12.5 : 13,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'UPT Dinas Sosial Provinsi Jawa Timur',
                                    style: TextStyle(
                                      fontSize: isMobile ? 10 : 11,
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                          // 2. Notification Icon with Badge & Pop Up Dropdown
                          CompositedTransformTarget(
                            link: _notifLayerLink,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  tooltip:
                                      'Notifikasi ($_unreadCount Belum Dibaca)',
                                  onPressed: _toggleNotificationPopup,
                                  icon: Icon(
                                    _unreadCount > 0
                                        ? Icons.notifications_active_rounded
                                        : Icons.notifications_none_rounded,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                    size: 26,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: _toggleNotificationPopup,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _unreadCount > 0
                                            ? const Color(0xFFDC2626)
                                            : (isDark
                                                ? const Color(0xFF334155)
                                                : const Color(0xFFCBD5E1)),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF1E293B)
                                              : Colors.white,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          if (_unreadCount > 0)
                                            BoxShadow(
                                              color: const Color(0xFFDC2626)
                                                  .withOpacity(0.4),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$_unreadCount',
                                          style: TextStyle(
                                            color: _unreadCount > 0
                                                ? Colors.white
                                                : (isDark
                                                    ? Colors.white70
                                                    : const Color(0xFF475569)),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                   ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),

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
                            requests: widget.requests,
                            vehicles: allVehicles,
                            onVerify: widget.onVerify,
                          ),
                          AdminLoansTab(
                            requests: widget.requests,
                            onVerify: widget.onVerify,
                            onReturn: widget.onReturn,
                          ),
                          AdminCalendarTab(
                            requests: widget.requests,
                            vehicles: allVehicles,
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
                          if (_isSuperAdmin)
                            AdminReportsTab(
                              requests: widget.requests,
                              vehicles: allVehicles,
                              users: allUsers,
                            ),
                          AdminPerformanceTab(
                            requests: widget.requests,
                            vehicles: allVehicles,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}

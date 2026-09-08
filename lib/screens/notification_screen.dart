import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/notification_model.dart';
import 'package:simodis_jatim/widgets/app_header_profile_avatar.dart';
import 'package:simodis_jatim/screens/notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  final List<AppNotification> notifications;
  final VoidCallback onClearAll;
  final Function(int)? onNavigateTab;

  const NotificationScreen({
    super.key,
    required this.notifications,
    required this.onClearAll,
    this.onNavigateTab,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  DateTime? _selectedMonth;

  static const _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String _monthLabel(DateTime month) =>
      '${_monthNames[month.month - 1]} ${month.year}';

  List<DateTime> get _availableMonths {
    final months = <String, DateTime>{};
    for (final notification in widget.notifications) {
      final month = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
      );
      months['${month.year}-${month.month}'] = month;
    }
    final result = months.values.toList()..sort((a, b) => b.compareTo(a));
    return result;
  }

  List<AppNotification> _filteredNotifications() {
    final selectedMonth = _selectedMonth;
    if (selectedMonth == null) return widget.notifications;
    return widget.notifications.where((notification) {
      return notification.createdAt.year == selectedMonth.year &&
          notification.createdAt.month == selectedMonth.month;
    }).toList();
  }

  void _navigateToNotificationDetail(AppNotification item) {
    setState(() {
      item.isRead = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(notification: item),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = widget.notifications.where((n) => !n.isRead).length;
    final filteredNotifications = _filteredNotifications();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Informasi terbaru aktivitas akun Anda',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AppHeaderProfileAvatar(
                  onTap: () => widget.onNavigateTab?.call(4),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Pusat Aktivitas
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF24487A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF24487A).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pusat Aktivitas & Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$unreadCount notifikasi baru belum dibaca',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter bulan dan aksi baca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DateTime?>(
                    initialValue: _selectedMonth,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: 'Filter bulan',
                      labelStyle: const TextStyle(fontSize: 11),
                      prefixIcon: const Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<DateTime?>(
                        value: null,
                        child: Text(
                          'Semua bulan',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ..._availableMonths.map(
                        (month) => DropdownMenuItem<DateTime?>(
                          value: month,
                          child: Text(
                            _monthLabel(month),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (month) =>
                        setState(() => _selectedMonth = month),
                  ),
                ),
                const SizedBox(width: 10),
                if (unreadCount > 0)
                  InkWell(
                    onTap: () {
                      widget.onClearAll();
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.done_all_rounded,
                            size: 14,
                            color: Color(0xFF2563EB),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Tandai Telah Dibaca',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // List 10 Notifikasi
          Expanded(
            child: filteredNotifications.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada notifikasi',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifications[index];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification item) {
    Color iconBg;
    Color iconColor;
    IconData icon;
    String tagLabel;
    Color tagBg;
    Color tagTextColor;

    switch (item.type) {
      case NotificationType.welcome:
        iconBg = const Color(0xFFEFF6FF);
        iconColor = const Color(0xFF2563EB);
        icon = Icons.waving_hand_rounded;
        tagLabel = 'Informasi Akun';
        tagBg = const Color(0xFFDBEAFE);
        tagTextColor = const Color(0xFF1E40AF);
        break;
      case NotificationType.submitted:
        iconBg = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        icon = Icons.hourglass_top_rounded;
        tagLabel = 'Menunggu Verifikasi';
        tagBg = const Color(0xFFFEF3C7);
        tagTextColor = const Color(0xFFB45309);
        break;
      case NotificationType.approved:
        iconBg = const Color(0xFFDCFCE7);
        iconColor = const Color(0xFF16A34A);
        icon = Icons.check_circle_rounded;
        tagLabel = 'Disetujui Kasubag';
        tagBg = const Color(0xFFDCFCE7);
        tagTextColor = const Color(0xFF15803D);
        break;
      case NotificationType.rejected:
        iconBg = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFDC2626);
        icon = Icons.cancel_rounded;
        tagLabel = 'Pengajuan Ditolak';
        tagBg = const Color(0xFFFEE2E2);
        tagTextColor = const Color(0xFFB91C1C);
        break;
      case NotificationType.maintenance:
        iconBg = const Color(0xFFF3E8FF);
        iconColor = const Color(0xFF7E22CE);
        icon = Icons.build_circle_rounded;
        tagLabel = 'Pemeliharaan';
        tagBg = const Color(0xFFF3E8FF);
        tagTextColor = const Color(0xFF6B21A8);
        break;
      case NotificationType.reminder:
        iconBg = const Color(0xFFE0F2FE);
        iconColor = const Color(0xFF0284C7);
        icon = Icons.schedule_rounded;
        tagLabel = 'Pengingat Jadwal';
        tagBg = const Color(0xFFE0F2FE);
        tagTextColor = const Color(0xFF0369A1);
        break;
    }

    return InkWell(
      onTap: () => _navigateToNotificationDetail(item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF93C5FD),
            width: item.isRead ? 1 : 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: item.isRead ? 0.02 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tagLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: tagTextColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          if (!item.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.isRead
                          ? FontWeight.w600
                          : FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.3,
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

import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/notification_model.dart';
import 'package:simodis_jatim/widgets/app_header_profile_avatar.dart';
import 'package:simodis_jatim/screens/notification_detail_screen.dart';
import 'package:simodis_jatim/services/theme_service.dart';

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
    final isDark = ThemeService.isDarkMode;
    final unreadCount = widget.notifications.where((n) => !n.isRead).length;
    final filteredNotifications = _filteredNotifications();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Informasi terbaru aktivitas akun Anda',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DateTime?>(
                    initialValue: _selectedMonth,
                    isDense: true,
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      hintText: 'Filter Bulan',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                    items: [
                      DropdownMenuItem<DateTime?>(
                        value: null,
                        child: Text(
                          'Semua Bulan',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      ..._availableMonths.map(
                        (month) => DropdownMenuItem<DateTime?>(
                          value: month,
                          child: Text(
                            _monthLabel(month),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.done_all_rounded,
                            size: 14,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tandai Dibaca',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
    final isDark = ThemeService.isDarkMode;
    Color iconBg;
    Color iconColor;
    IconData icon;
    String tagLabel;
    Color tagBg;
    Color tagTextColor;

    switch (item.type) {
      case NotificationType.welcome:
        iconBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
        iconColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
        icon = Icons.waving_hand_rounded;
        tagLabel = 'Informasi Akun';
        tagBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
        tagTextColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);
        break;
      case NotificationType.submitted:
        iconBg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        icon = Icons.hourglass_top_rounded;
        tagLabel = 'Menunggu Verifikasi';
        tagBg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        tagTextColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309);
        break;
      case NotificationType.approved:
        iconBg = isDark ? const Color(0xFF166534) : const Color(0xFFDCFCE7);
        iconColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A);
        icon = Icons.check_circle_rounded;
        tagLabel = 'Disetujui Kasubag';
        tagBg = isDark ? const Color(0xFF166534) : const Color(0xFFDCFCE7);
        tagTextColor = isDark ? const Color(0xFFBBF7D0) : const Color(0xFF15803D);
        break;
      case NotificationType.rejected:
        iconBg = isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2);
        iconColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
        icon = Icons.cancel_rounded;
        tagLabel = 'Ditolak Aset';
        tagBg = isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2);
        tagTextColor = isDark ? const Color(0xFFFECACA) : const Color(0xFFB91C1C);
        break;
      case NotificationType.maintenance:
        iconBg = isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF);
        iconColor = isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE);
        icon = Icons.build_circle_rounded;
        tagLabel = 'Info Pemeliharaan';
        tagBg = isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF);
        tagTextColor = isDark ? const Color(0xFFE9D5FF) : const Color(0xFF6B21A8);
        break;
      case NotificationType.reminder:
        iconBg = isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE);
        iconColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
        icon = Icons.schedule_rounded;
        tagLabel = 'Pengingat Jadwal';
        tagBg = isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE);
        tagTextColor = isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0369A1);
        break;
    }

    return InkWell(
      onTap: () => _navigateToNotificationDetail(item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isDark
              ? (item.isRead ? const Color(0xFF1E293B) : const Color(0xFF1E3A8A).withValues(alpha: 0.35))
              : (item.isRead ? Colors.white : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? (item.isRead ? const Color(0xFF334155) : const Color(0xFF2563EB))
                : (item.isRead ? const Color(0xFFE2E8F0) : const Color(0xFF93C5FD)),
            width: item.isRead ? 1 : 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : (item.isRead ? 0.02 : 0.04)),
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
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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

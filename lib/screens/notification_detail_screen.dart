import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/notification_model.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class NotificationDetailScreen extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  Color _getIconBg(NotificationType type, bool isDark) {
    switch (type) {
      case NotificationType.welcome:
        return isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
      case NotificationType.submitted:
        return isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
      case NotificationType.approved:
        return isDark ? const Color(0xFF166534) : const Color(0xFFDCFCE7);
      case NotificationType.rejected:
        return isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2);
      case NotificationType.maintenance:
        return isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF);
      case NotificationType.reminder:
        return isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE);
    }
  }

  Color _getIconColor(NotificationType type, bool isDark) {
    switch (type) {
      case NotificationType.welcome:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
      case NotificationType.submitted:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
      case NotificationType.approved:
        return isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A);
      case NotificationType.rejected:
        return isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
      case NotificationType.maintenance:
        return isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE);
      case NotificationType.reminder:
        return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.welcome:
        return Icons.waving_hand_rounded;
      case NotificationType.submitted:
        return Icons.hourglass_top_rounded;
      case NotificationType.approved:
        return Icons.check_circle_rounded;
      case NotificationType.rejected:
        return Icons.cancel_rounded;
      case NotificationType.maintenance:
        return Icons.build_circle_rounded;
      case NotificationType.reminder:
        return Icons.schedule_rounded;
    }
  }

  String _getTagLabel(NotificationType type) {
    switch (type) {
      case NotificationType.welcome:
        return 'Informasi Akun';
      case NotificationType.submitted:
        return 'Menunggu Verifikasi';
      case NotificationType.approved:
        return 'Disetujui Kasubag';
      case NotificationType.rejected:
        return 'Pengajuan Ditolak';
      case NotificationType.maintenance:
        return 'Info Pemeliharaan';
      case NotificationType.reminder:
        return 'Pengingat Jadwal';
    }
  }

  Widget _buildTipCard(NotificationType type, bool isDark) {
    Color bg;
    Color border;
    Color textColor;
    IconData icon;
    String title;
    String content;

    switch (type) {
      case NotificationType.approved:
        bg = isDark ? const Color(0xFF166534) : const Color(0xFFF0FDF4);
        border = isDark ? const Color(0xFF22C55E) : const Color(0xFFBBF7D0);
        textColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534);
        icon = Icons.check_circle_outline_rounded;
        title = 'Petunjuk Langkah Selanjutnya';
        content =
            'Silakan bawa Nota Dinas / Surat Tugas ke Loket Pengelola Aset Gedung A Dinsos Jatim untuk serah terima kunci kontak dan kendaraan dinas.';
        break;
      case NotificationType.rejected:
        bg = isDark ? const Color(0xFF991B1B) : const Color(0xFFFEF2F2);
        border = isDark ? const Color(0xFFEF4444) : const Color(0xFFFECACA);
        textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
        icon = Icons.info_outline_rounded;
        title = 'Petunjuk Penolakan Pengajuan';
        content =
            'Permohonan armada belum dapat disetujui. Periksa kembali kelengkapan administrasi Nota Dinas atau konsultasikan dengan atasan/Kasubag Umum untuk rekomendasi jadwal armada pengganti.';
        break;
      case NotificationType.maintenance:
        bg = isDark ? const Color(0xFF581C87) : const Color(0xFFFAF5FF);
        border = isDark ? const Color(0xFFA855F7) : const Color(0xFFE9D5FF);
        textColor = isDark ? const Color(0xFFE9D5FF) : const Color(0xFF6B21A8);
        icon = Icons.car_repair_rounded;
        title = 'Status Pemeliharaan Berkala';
        content =
            'Armada yang bersangkutan sedang dalam pemeliharaan rutin keselamatan jalan demi kelancaran tugas dinas sosial. Unit akan kembali tersedia setelah pengecekan teknis selesai.';
        break;
      case NotificationType.submitted:
        bg = isDark ? const Color(0xFF78350F) : const Color(0xFFFFFBEB);
        border = isDark ? const Color(0xFFF59E0B) : const Color(0xFFFDE68A);
        textColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309);
        icon = Icons.hourglass_bottom_rounded;
        title = 'Status Antrean Verifikasi';
        content =
            'Permohonan Anda telah tersimpan di sistem antrean Kasubag Umum & Aset. Proses verifikasi biasanya membutuhkan waktu 1-3 jam pada hari kerja aktif.';
        break;
      case NotificationType.welcome:
      case NotificationType.reminder:
        bg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
        border = isDark ? const Color(0xFF3B82F6) : const Color(0xFFBFDBFE);
        textColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);
        icon = Icons.lightbulb_rounded;
        title = 'Ketentuan Operasional Dinsos Jatim';
        content =
            'Gunakan selalu armada dinas untuk kepentingan kedinasan resmi Pemprov Jawa Timur. Laporkan sisa BBM dan angka kilometer akhir pada lembar pengembalian BAST.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final iconBg = _getIconBg(notification.type, isDark);
    final iconColor = _getIconColor(notification.type, isDark);
    final icon = _getIcon(notification.type);
    final tagLabel = _getTagLabel(notification.type);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
          child: SafeArea(
            bottom: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Kembali',
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Detail Notifikasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Informasi lengkap aktivitas dan pengajuan armada',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF24487A),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 750));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU UTAMA NOTIFIKASI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: iconColor, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tagLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: iconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFEDF2F7),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.short_text_rounded,
                          size: 18,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                              height: 1.4,
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

            // KARTU METADATA & NOMOR REFERENSI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Pengenal & Jadwal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMetaRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Tanggal Diterima',
                    value:
                        '${notification.createdAt.day.toString().padLeft(2, '0')}/${notification.createdAt.month.toString().padLeft(2, '0')}/${notification.createdAt.year} (${notification.time})',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildMetaRow(
                    icon: Icons.tag_rounded,
                    label: 'ID Notifikasi',
                    value: '#NOTIF-${notification.id}',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildMetaRow(
                    icon: Icons.mark_email_read_outlined,
                    label: 'Status Keterbacaan',
                    value: notification.isRead
                        ? 'Telah Dibaca (Sudah Dilihat)'
                        : 'Baru (Belum Dibaca)',
                    valueColor: notification.isRead
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF2563EB),
                    isDark: isDark,
                  ),
                  Divider(height: 24, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                  _buildMetaRow(
                    icon: Icons.shield_outlined,
                    label: 'Status Berkas',
                    value: 'Terkonfirmasi di Database SIP-K',
                    valueColor: const Color(0xFF16A34A),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // KARTU PENJELASAN DETAIL LENGKAP
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 18,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rincian Informasi & Deskripsi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification.detailContent,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      height: 1.6,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PETUNJUK KHUSUS SESUAI TIPE NOTIFIKASI
            _buildTipCard(notification.type, isDark),
            const SizedBox(height: 24),

            // TOMBOL KEMBALI
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text(
                  'Kembali ke Daftar Notifikasi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24487A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isDark ? Colors.white : const Color(0xFF1E293B)),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simodis_jatim/models/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  Color _getIconBg(NotificationType type) {
    switch (type) {
      case NotificationType.welcome:
        return const Color(0xFFEFF6FF);
      case NotificationType.submitted:
        return const Color(0xFFFEF3C7);
      case NotificationType.approved:
        return const Color(0xFFDCFCE7);
      case NotificationType.rejected:
        return const Color(0xFFFEE2E2);
      case NotificationType.maintenance:
        return const Color(0xFFF3E8FF);
      case NotificationType.reminder:
        return const Color(0xFFE0F2FE);
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.welcome:
        return const Color(0xFF2563EB);
      case NotificationType.submitted:
        return const Color(0xFFD97706);
      case NotificationType.approved:
        return const Color(0xFF16A34A);
      case NotificationType.rejected:
        return const Color(0xFFDC2626);
      case NotificationType.maintenance:
        return const Color(0xFF7E22CE);
      case NotificationType.reminder:
        return const Color(0xFF0284C7);
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
        return 'Pemeliharaan Unit';
      case NotificationType.reminder:
        return 'Pengingat Dinas';
    }
  }

  Widget _buildGuidanceBox(NotificationType type) {
    Color bg;
    Color border;
    Color textColor;
    IconData icon;
    String title;
    String content;

    switch (type) {
      case NotificationType.approved:
        bg = const Color(0xFFF0FDF4);
        border = const Color(0xFFBBF7D0);
        textColor = const Color(0xFF15803D);
        icon = Icons.verified_user_rounded;
        title = 'Petunjuk Pengambilan Armada';
        content =
            'Pengajuan telah disahkan. Silakan tunjukkan berkas Nota Dinas / lembar SPK digital ini ke loket pengelola pool kendaraan untuk serah terima kunci kontak, STNK, dan pengecekan fisik unit.';
        break;
      case NotificationType.rejected:
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFECACA);
        textColor = const Color(0xFFB91C1C);
        icon = Icons.info_outline_rounded;
        title = 'Petunjuk Penolakan Pengajuan';
        content =
            'Permohonan armada belum dapat disetujui. Periksa kembali kelengkapan administrasi Nota Dinas atau konsultasikan dengan atasan/Kasubag Umum untuk rekomendasi jadwal armada pengganti.';
        break;
      case NotificationType.maintenance:
        bg = const Color(0xFFFAF5FF);
        border = const Color(0xFFE9D5FF);
        textColor = const Color(0xFF6B21A8);
        icon = Icons.car_repair_rounded;
        title = 'Status Pemeliharaan Berkala';
        content =
            'Armada yang bersangkutan sedang dalam pemeliharaan rutin keselamatan jalan demi kelancaran tugas dinas sosial. Unit akan kembali tersedia setelah pengecekan teknis selesai.';
        break;
      case NotificationType.submitted:
        bg = const Color(0xFFFFFBEB);
        border = const Color(0xFFFDE68A);
        textColor = const Color(0xFFB45309);
        icon = Icons.hourglass_bottom_rounded;
        title = 'Status Antrean Verifikasi';
        content =
            'Permohonan Anda telah tersimpan di sistem antrean Kasubag Umum & Aset. Proses verifikasi biasanya membutuhkan waktu 1-3 jam pada hari kerja aktif.';
        break;
      case NotificationType.welcome:
      case NotificationType.reminder:
        bg = const Color(0xFFEFF6FF);
        border = const Color(0xFFBFDBFE);
        textColor = const Color(0xFF1E40AF);
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
    final iconBg = _getIconBg(notification.type);
    final iconColor = _getIconColor(notification.type);
    final icon = _getIcon(notification.type);
    final tagLabel = _getTagLabel(notification.type);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // 1. APP BAR RESMI SIP-K
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
          child: SafeArea(
            bottom: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF1E293B),
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Kembali',
                ),
                const SizedBox(width: 4),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Detail Notifikasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Informasi lengkap aktivitas dan pengajuan armada',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
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
      // 2. KONTEN DETAIL HALAMAN PENUH
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU UTAMA NOTIFIKASI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Kategori & Waktu
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
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notification.time,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Judul Notifikasi
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Ringkasan Cepat
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEDF2F7)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.short_text_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification.message,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Pengenal & Jadwal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Waktu Lengkap
                  _buildMetaRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Tanggal & Waktu',
                    value: notification.fullDate,
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),

                  // Nomor Referensi Resmi
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 110,
                        child: Text(
                          'No. Registrasi',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                notification.referenceNumber,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: notification.referenceNumber,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Nomor referensi ${notification.referenceNumber} disalin!',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 14,
                                      color: Color(0xFF24487A),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Salin',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF24487A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),

                  // Status Verifikasi Akun
                  _buildMetaRow(
                    icon: Icons.shield_outlined,
                    label: 'Status Berkas',
                    value: 'Terkonfirmasi di Database SIP-K',
                    valueColor: const Color(0xFF16A34A),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.article_outlined,
                        size: 18,
                        color: Color(0xFF24487A),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Rincian Informasi & Deskripsi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification.detailContent,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF334155),
                      height: 1.6,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PETUNJUK KHUSUS SESUAI TIPE NOTIFIKASI
            _buildGuidanceBox(notification.type),
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
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}

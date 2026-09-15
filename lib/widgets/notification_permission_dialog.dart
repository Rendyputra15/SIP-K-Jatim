import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simodis_jatim/services/notification_permission_service.dart';

class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onGranted;
  final VoidCallback onDismissed;

  const NotificationPermissionDialog({
    super.key,
    required this.onGranted,
    required this.onDismissed,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onGranted,
    required VoidCallback onDismissed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => PopScope(
            canPop: false,
            child: NotificationPermissionDialog(
              onGranted: () {
                Navigator.of(ctx).pop();
                onGranted();
              },
              onDismissed: () {
                Navigator.of(ctx).pop();
                onDismissed();
              },
            ),
          ),
    );
  }

  Future<void> _handleAllow(BuildContext context) async {
    // 1. Memanggil Pop-up Permission Bawaan Sistem HP (Android/iOS)
    final status = await NotificationPermissionService.requestPermission(
      context,
    );

    if (status.isGranted || kIsWeb) {
      onGranted();
    } else if (status.isPermanentlyDenied) {
      // Jika izin diblokir secara permanen di sistem HP
      if (context.mounted) {
        NotificationPermissionService.showOpenSettingsDialog(
          context,
          onCancel: onDismissed,
        );
      }
    } else {
      // Jika ditolak sekali
      onDismissed();
    }
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      elevation: 10,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Badge Header
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),

              // Judul & Deskripsi
              const Text(
                'Aktifkan Notifikasi SIP-K',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Dapatkan pembaruan instan pengajuan armada dan nota dinas di perangkat Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),

              // Daftar Manfaat Notifikasi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildBenefitItem(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: const Color(0xFF16A34A),
                      title: 'Status Verifikasi Real-time',
                      desc: 'Ketahui saat pengajuan disetujui atau ditolak.',
                    ),
                    const Divider(height: 12, color: Color(0xFFE2E8F0)),
                    _buildBenefitItem(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF2563EB),
                      title: 'Penerbitan Nota Dinas',
                      desc: 'Pemberitahuan dokumen resmi siap dicetak/diunduh.',
                    ),
                    const Divider(height: 12, color: Color(0xFFE2E8F0)),
                    _buildBenefitItem(
                      icon: Icons.alarm_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Pengingat Pengembalian Unit',
                      desc: 'Pengingat otomatis sebelum batas waktu peminjaman.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Tombol 1: Izinkan (Memicu pop-up izin OS HP)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleAllow(context),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text(
                    'Izinkan Notifikasi',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24487A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Tombol 2: Buka Pengaturan HP
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await NotificationPermissionService.openSettings();
                  },
                  icon: const Icon(Icons.settings_outlined, size: 14),
                  label: const Text(
                    'Buka Pengaturan HP',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF24487A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),

              // Tombol 3: Nanti Saja
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onDismissed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    foregroundColor: const Color(0xFF64748B),
                  ),
                  child: const Text(
                    'Nanti Saja',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

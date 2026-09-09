import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  /// Meminta izin notifikasi langsung dari sistem OS (memunculkan pop-up izin bawaan HP).
  /// Jika izin telah ditolak permanen, akan menawarkan tombol menuju Pengaturan HP.
  static Future<PermissionStatus> requestPermission(BuildContext context) async {
    try {
      final status = await Permission.notification.request();

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          showOpenSettingsDialog(context);
        }
      }

      return status;
    } catch (_) {
      return PermissionStatus.denied;
    }
  }

  /// Membuka halaman aplikasi di Pengaturan / Settings HP pengguna
  static Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Cek apakah izin notifikasi telah aktif
  static Future<bool> isGranted() async {
    try {
      return await Permission.notification.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Menampilkan dialog edukasi yang mengarahkan pengguna ke Pengaturan HP
  static void showOpenSettingsDialog(
    BuildContext context, {
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings_suggest_rounded,
                color: Color(0xFF24487A),
                size: 32,
              ),
            ),
            title: const Text(
              'Izin Notifikasi Nonaktif',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            content: const Text(
              'Izin notifikasi dinonaktifkan pada perangkat Anda. Buka Pengaturan HP untuk mengaktifkannya agar tidak ketinggalan update persetujuan peminjaman armada dan penerbitan nota dinas.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onCancel?.call();
                },
                child: const Text('Nanti Saja'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await openSettings();
                },
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('Buka Pengaturan HP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24487A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

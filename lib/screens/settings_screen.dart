import 'package:flutter/material.dart';
import 'package:simodis_jatim/services/notification_permission_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _largeTextMode = false;
  bool _notifStatusEnabled = true;
  bool _notifReminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF334A5C),
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
        children: [
          const Text(
            'Sesuaikan pengalaman aplikasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF334A5C),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Atur tampilan dan pemberitahuan agar SIP-K tetap nyaman digunakan setiap hari.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6D8190)),
          ),
          const SizedBox(height: 22),
          _buildSection(
            title: 'Tampilan',
            icon: Icons.palette_outlined,
            children: [
              _buildSwitchTile(
                icon: Icons.text_fields_rounded,
                title: 'Teks lebih besar',
                subtitle:
                    'Perbesar teks untuk membaca informasi dengan lebih nyaman.',
                value: _largeTextMode,
                onChanged: (value) => setState(() => _largeTextMode = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Notifikasi',
            icon: Icons.notifications_none_rounded,
            children: [
              _buildSwitchTile(
                icon: Icons.assignment_turned_in_outlined,
                title: 'Status pengajuan dan SPK',
                subtitle: 'Terima kabar saat pengajuan diverifikasi.',
                value: _notifStatusEnabled,
                onChanged: (value) =>
                    setState(() => _notifStatusEnabled = value),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildSwitchTile(
                icon: Icons.schedule_rounded,
                title: 'Pengingat pengembalian',
                subtitle: 'Dapatkan pengingat sebelum waktu dinas berakhir.',
                value: _notifReminderEnabled,
                onChanged: (value) =>
                    setState(() => _notifReminderEnabled = value),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.settings_suggest_rounded,
                    color: Color(0xFF24487A),
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Buka Pengaturan Notifikasi HP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                subtitle: const Text(
                  'Kelola izin dan suara notifikasi langsung di pengaturan sistem perangkat.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                onTap: () => NotificationPermissionService.openSettings(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD6E2E9)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF6F91A8)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pengaturan tersimpan otomatis di perangkat ini. Anda dapat mengubahnya kapan saja.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF55758D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E8ED)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF6F91A8)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334A5C),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      secondary: Icon(icon, color: const Color(0xFF7893A8)),
      activeThumbColor: const Color(0xFF6F91A8),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Color(0xFF718592)),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:simodis_jatim/services/notification_permission_service.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifStatusEnabled = true;
  bool _notifReminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final isLarge = ThemeService.isLargeText;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F7FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE0E8ED);
    final titleColor = isDark ? Colors.white : const Color(0xFF334A5C);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D8190);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final infoBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEAF1F5);
    final infoBorder = isDark ? const Color(0xFF334155) : const Color(0xFFD6E2E9);
    final infoTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF55758D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF334A5C),
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF24487A),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 750));
          if (mounted) setState(() {});
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          children: [
          Text(
            'Sesuaikan pengalaman aplikasi',
            style: TextStyle(
              fontSize: isLarge ? 22 : 20,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Atur tampilan dan pemberitahuan agar SIP-K tetap nyaman digunakan setiap hari.',
            style: TextStyle(
              fontSize: isLarge ? 14 : 12,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 22),

          // SEKSI TAMPILAN
          _buildSection(
            title: 'Tampilan',
            icon: Icons.palette_outlined,
            cardColor: cardColor,
            borderColor: borderColor,
            titleColor: titleColor,
            children: [
              _buildSwitchTile(
                icon: isDark ? Icons.dark_mode_rounded : Icons.dark_mode_outlined,
                title: 'Mode Gelap',
                subtitle: 'Tampilan warna gelap khusus untuk antarmuka pengguna (user).',
                value: isDark,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                onChanged: (value) {
                  setState(() {
                    ThemeService.setDarkMode(value);
                  });
                },
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
              _buildSwitchTile(
                icon: Icons.text_fields_rounded,
                title: 'Teks lebih besar',
                subtitle: 'Perbesar teks untuk membaca informasi dengan lebih nyaman.',
                value: isLarge,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                onChanged: (value) {
                  setState(() {
                    ThemeService.setLargeText(value);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SEKSI NOTIFIKASI
          _buildSection(
            title: 'Notifikasi',
            icon: Icons.notifications_none_rounded,
            cardColor: cardColor,
            borderColor: borderColor,
            titleColor: titleColor,
            children: [
              _buildSwitchTile(
                icon: Icons.assignment_turned_in_outlined,
                title: 'Status pengajuan dan SPK',
                subtitle: 'Terima kabar saat pengajuan diverifikasi.',
                value: _notifStatusEnabled,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                onChanged: (value) => setState(() => _notifStatusEnabled = value),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
              _buildSwitchTile(
                icon: Icons.schedule_rounded,
                title: 'Pengingat pengembalian',
                subtitle: 'Dapatkan pengingat sebelum waktu dinas berakhir.',
                value: _notifReminderEnabled,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                onChanged: (value) => setState(() => _notifReminderEnabled = value),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: dividerColor),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.settings_suggest_rounded,
                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Buka Pengaturan Notifikasi HP',
                  style: TextStyle(
                    fontSize: isLarge ? 14 : 13,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                subtitle: Text(
                  'Kelola izin dan suara notifikasi langsung di pengaturan sistem perangkat.',
                  style: TextStyle(
                    fontSize: isLarge ? 12 : 11,
                    color: subtitleColor,
                  ),
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

          // INFO BANNER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: infoBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF6F91A8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pengaturan tersimpan otomatis di perangkat ini. Anda dapat mengubahnya kapan saja.',
                    style: TextStyle(
                      fontSize: isLarge ? 13 : 12,
                      height: 1.4,
                      color: infoTextColor,
                    ),
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color cardColor,
    required Color borderColor,
    required Color titleColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: ThemeService.isDarkMode
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF6F91A8),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
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
    required Color titleColor,
    required Color subtitleColor,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = ThemeService.isDarkMode;
    final isLarge = ThemeService.isLargeText;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      secondary: Icon(
        icon,
        color: isDark
            ? (value ? const Color(0xFF60A5FA) : const Color(0xFF94A3B8))
            : (value ? const Color(0xFF2563EB) : const Color(0xFF7893A8)),
      ),
      activeThumbColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      activeTrackColor: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFBFDBFE),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isLarge ? 14 : 13,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: isLarge ? 12 : 11,
          color: subtitleColor,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

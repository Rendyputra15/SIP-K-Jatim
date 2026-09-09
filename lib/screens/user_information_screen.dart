import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/screens/edit_profile_screen.dart';
import 'package:simodis_jatim/services/theme_service.dart';
import 'package:simodis_jatim/widgets/app_image.dart';

class UserInformationScreen extends StatefulWidget {
  final String name;
  final String nip;
  final String position;
  final String department;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final Function(UserProfile updatedProfile)? onProfileUpdated;

  const UserInformationScreen({
    super.key,
    required this.name,
    required this.nip,
    required this.position,
    required this.department,
    this.email = 'alamsyah@dinsos.jatimprov.go.id',
    this.phone = '0812-3456-7890',
    this.profileImageUrl,
    this.onProfileUpdated,
  });

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  late UserProfile _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentProfile = UserProfile(
      name: widget.name,
      nip: widget.nip,
      position: widget.position,
      department: widget.department,
      email: widget.email,
      phone: widget.phone,
      profileImageUrl: widget.profileImageUrl,
    );
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          profile: _currentProfile,
          onSave: (up) {
            setState(() => _currentProfile = up);
            widget.onProfileUpdated?.call(up);
          },
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() => _currentProfile = updated);
      widget.onProfileUpdated?.call(updated);
    }
  }

  Widget _buildAvatar() {
    final img = _currentProfile.profileImageUrl;
    if (img == 'avatar:pegawai-1') {
      return const CircleAvatar(
        radius: 30,
        backgroundColor: Color(0xFFDCEBE8),
        child: Icon(
          Icons.badge_rounded,
          color: Color(0xFF5D8E86),
          size: 34,
        ),
      );
    }
    if (img == 'avatar:pegawai-2') {
      return const CircleAvatar(
        radius: 30,
        backgroundColor: Color(0xFFE6E1F0),
        child: Icon(
          Icons.support_agent_rounded,
          color: Color(0xFF7D719C),
          size: 34,
        ),
      );
    }
    if (img != null && imageProviderFromSource(img) != null) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: const Color(0xFFE2E8F0),
        backgroundImage: imageProviderFromSource(img),
      );
    }

    return const CircleAvatar(
      radius: 30,
      backgroundColor: Color(0xFFFBBF24),
      child: Icon(
        Icons.person_rounded,
        size: 34,
        color: Color(0xFF1E293B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.onProfileUpdated?.call(_currentProfile);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _currentProfile);
            },
          ),
          title: const Text(
            'Informasi Pengguna',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            // KARTU HEADER PEGAWAI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF24487A),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1824487A),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentProfile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Profil pegawai SIP-K',
                          style: TextStyle(
                            color: Color(0xFFDBEAFE),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // KARTU INFORMASI KEPEGAWAIAN
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildInformationRow(
                    Icons.person_outline_rounded,
                    'Nama Lengkap',
                    _currentProfile.name,
                    isDark,
                  ),
                  _buildDivider(isDark),
                  _buildInformationRow(
                    Icons.badge_outlined,
                    'NIP',
                    _currentProfile.nip,
                    isDark,
                  ),
                  _buildDivider(isDark),
                  _buildInformationRow(
                    Icons.work_outline_rounded,
                    'Jabatan',
                    _currentProfile.position,
                    isDark,
                  ),
                  _buildDivider(isDark),
                  _buildInformationRow(
                    Icons.business_outlined,
                    'Bidang',
                    _currentProfile.department,
                    isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // KARTU INFORMASI KONTAK & AKUN
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildInformationRow(
                    Icons.email_outlined,
                    'Email Kedinasan',
                    _currentProfile.email,
                    isDark,
                  ),
                  _buildDivider(isDark),
                  _buildInformationRow(
                    Icons.phone_outlined,
                    'Nomor WhatsApp / HP',
                    _currentProfile.phone,
                    isDark,
                  ),
                  _buildDivider(isDark),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                              : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          size: 19,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Akun',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Aktif (ASN Pegawai Dinsos)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TOMBOL UTAMA EDIT PROFIL
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _openEditProfile,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text(
                  'Edit Profil',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF24487A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 24,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildInformationRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 19,
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

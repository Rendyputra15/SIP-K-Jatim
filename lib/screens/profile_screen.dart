import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/screens/loan_history_screen.dart';
import 'package:simodis_jatim/screens/login_screen.dart';
import 'package:simodis_jatim/screens/settings_screen.dart';
import 'package:simodis_jatim/screens/user_information_screen.dart';
import 'package:simodis_jatim/widgets/nota_dinas_dialog.dart';
import 'package:simodis_jatim/widgets/app_image.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  final List<LoanRequest> loans;
  final Function(int) onNavigateTab;
  final UserProfile? initialProfile;
  final Function(UserProfile)? onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.loans,
    required this.onNavigateTab,
    this.initialProfile,
    this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _largeTextMode = false;
  // State Foto Profil
  String? _profileImageUrl;
  late UserProfile _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = widget.initialProfile ??
        UserProfile(
          name: 'Alamsyah',
          nip: '199503152020121002',
          position: 'Staf Pelaksana',
          department: 'Dinas Sosial Jawa Timur',
          email: 'alamsyah@dinsos.jatimprov.go.id',
          phone: '0812-3456-7890',
          profileImageUrl: _profileImageUrl,
        );
    _profileImageUrl = _userProfile.profileImageUrl;
  }

  void _updateProfile(UserProfile newProfile) {
    setState(() {
      _userProfile = newProfile;
      _profileImageUrl = newProfile.profileImageUrl;
    });
    widget.onProfileUpdated?.call(newProfile);
  }


  Widget _buildEmployeeAvatar({
    required String avatarId,
    required Color backgroundColor,
    required Color iconColor,
    double radius = 28,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            child: Icon(
              avatarId == 'pegawai-2'
                  ? Icons.support_agent_rounded
                  : Icons.badge_rounded,
              color: iconColor,
              size: radius * 1.15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentAvatar() {
    final imageSource = _profileImageUrl;
    if (imageSource == null) {
      return const Icon(Icons.person, size: 42, color: Color(0xFF55758D));
    }
    if (imageSource == 'avatar:pegawai-1') {
      return _buildEmployeeAvatar(
        avatarId: 'pegawai-1',
        backgroundColor: const Color(0xFFDCEBE8),
        iconColor: const Color(0xFF5D8E86),
        radius: 38,
      );
    }
    if (imageSource == 'avatar:pegawai-2') {
      return _buildEmployeeAvatar(
        avatarId: 'pegawai-2',
        backgroundColor: const Color(0xFFE6E1F0),
        iconColor: const Color(0xFF7D719C),
        radius: 38,
      );
    }
    return const SizedBox.shrink();
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // DIALOG GANTI FOTO PROFIL
  void _showChangePhotoDialog(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ganti Foto Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Gunakan file PNG, JPG, atau JPEG dari perangkat Anda:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pilih avatar pegawai',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334A5C),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEmployeeAvatar(
                    avatarId: 'pegawai-1',
                    backgroundColor: const Color(0xFFDCEBE8),
                    iconColor: const Color(0xFF5D8E86),
                    onTap: () {
                      _updateProfile(_userProfile.copyWith(profileImageUrl: 'avatar:pegawai-1'));
                      Navigator.pop(ctx);
                    },
                  ),
                  _buildEmployeeAvatar(
                    avatarId: 'pegawai-2',
                    backgroundColor: const Color(0xFFE6E1F0),
                    iconColor: const Color(0xFF7D719C),
                    onTap: () {
                      _updateProfile(_userProfile.copyWith(profileImageUrl: 'avatar:pegawai-2'));
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked == null) return;
                    if (!isSupportedImageFile(picked.name)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pilih file dengan format PNG, JPG, atau JPEG.',
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    final bytes = await picked.readAsBytes();
                    if (!context.mounted) return;
                    _updateProfile(
                      _userProfile.copyWith(
                        profileImageUrl: imageDataUri(picked.name, bytes),
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Pilih File Gambar'),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _updateProfile(
                          UserProfile(
                            name: _userProfile.name,
                            nip: _userProfile.nip,
                            position: _userProfile.position,
                            department: _userProfile.department,
                            email: _userProfile.email,
                            phone: _userProfile.phone,
                            profileImageUrl: null,
                          ),
                        );
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Hapus Foto',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24487A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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

  // MODAL PENGATURAN LENGKAP DENGAN MODE AKSESIBILITAS
  void _showSettingsModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  // MODAL DETAIL POP-UP RIWAYAT PINJAMAN
  void _showLoanDetailDialog(BuildContext context, LoanRequest item) {
    final isDark = ThemeService.isDarkMode;
    Color statusBg;
    Color statusTextColor;
    String statusText;

    switch (item.status) {
      case LoanStatus.disetujui:
      case LoanStatus.approved:
        statusBg = isDark ? const Color(0xFF166534) : const Color(0xFFDCFCE7);
        statusTextColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D);
        statusText = 'DISETUJUI';
        break;
      case LoanStatus.ditolak:
      case LoanStatus.rejected:
        statusBg = isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2);
        statusTextColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
        statusText = 'DITOLAK';
        break;
      case LoanStatus.dibatalkan:
        statusBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        statusTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
        statusText = 'DIBATALKAN';
        break;
      case LoanStatus.selesai:
        statusBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
        statusTextColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
        statusText = 'SELESAI';
        break;
      case LoanStatus.menunggu:
      case LoanStatus.pending:
        statusBg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        statusTextColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        statusText = 'MENUNGGU';
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.vehicleName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID Permohonan: #${item.id.length > 8 ? item.id.substring(item.id.length - 8) : item.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 14),
                _buildDetailRow(
                  Icons.person_outline_rounded,
                  'Peminjam',
                  item.borrowerName,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  Icons.business_rounded,
                  'Bidang / Seksi',
                  item.department.isEmpty ? '-' : item.department,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  Icons.calendar_month_rounded,
                  'Jadwal Tugas',
                  '${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}',
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  Icons.near_me_rounded,
                  'Tujuan Instansi',
                  item.destination,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  Icons.location_on_outlined,
                  'Alamat Tujuan',
                  item.destinationAddress.isEmpty
                      ? '-'
                      : item.destinationAddress,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  Icons.description_outlined,
                  'Keperluan Dinas',
                  item.purposeDescription.isEmpty
                      ? '-'
                      : item.purposeDescription,
                ),
                if (item.spkNumber != null) ...[
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    Icons.badge_outlined,
                    'Nomor SPK Dinas',
                    item.spkNumber!,
                  ),
                ],
                if (item.returnOdometer != null ||
                    item.returnNotes != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan BAST Pengembalian Unit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF24487A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (item.returnOdometer != null)
                          Text(
                            'Odometer Akhir: ${item.returnOdometer} KM',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                          ),
                        if (item.returnFuel != null)
                          Text(
                            'Sisa BBM: ${item.returnFuel}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                          ),
                        if (item.returnNotes != null &&
                            item.returnNotes!.isNotEmpty)
                          Text(
                            'Kondisi: ${item.returnNotes}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                // Tombol Buka & Cetak Softfile Nota Dinas (Hanya muncul jika status Disetujui)
                if (item.status == LoanStatus.disetujui ||
                    item.status == LoanStatus.approved) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => NotaDinasDialog(loan: item),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text(
                        'Buka & Cetak Softfile Nota Dinas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24487A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final isDark = ThemeService.isDarkMode;
    final double labelSize = _largeTextMode ? 14 : 12;
    final double valueSize = _largeTextMode ? 14 : 12;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: _largeTextMode ? 18 : 16,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: _largeTextMode ? 120 : 105,
          child: Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
        Text(
          ': ',
          style: TextStyle(fontSize: labelSize, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  void _showHistoryModal(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoanHistoryScreen(
          loans: widget.loans,
          onLoanTap: (loan) => _showLoanDetailDialog(context, loan),
          onLoanCancelled: (_) => setState(() {}),
        ),
      ),
    );
    if (context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Riwayat Semua Peminjaman',
              style: TextStyle(
                fontSize: _largeTextMode ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ketuk pada salah satu kartu untuk melihat detail lengkap',
              style: TextStyle(
                fontSize: _largeTextMode ? 13 : 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: widget.loans.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada riwayat pengajuan armada.',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.loans.length,
                      itemBuilder: (context, i) {
                        final item = widget.loans[i];
                        final isDisetujui =
                            item.status == LoanStatus.disetujui ||
                            item.status == LoanStatus.approved;
                        final isDitolak =
                            item.status == LoanStatus.ditolak ||
                            item.status == LoanStatus.rejected;

                        return InkWell(
                          onTap: () => _showLoanDetailDialog(context, item),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                     Expanded(
                                      child: Text(
                                        item.vehicleName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: _largeTextMode ? 15 : 13,
                                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDisetujui
                                            ? const Color(0xFFDCFCE7)
                                            : (isDitolak
                                                  ? const Color(0xFFFEE2E2)
                                                  : const Color(0xFFFEF3C7)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.status.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDisetujui
                                              ? const Color(0xFF15803D)
                                              : (isDitolak
                                                    ? const Color(0xFFB91C1C)
                                                    : const Color(0xFFB45309)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tujuan: ${item.destination}',
                                  style: TextStyle(
                                    fontSize: _largeTextMode ? 14 : 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Jadwal: ${_formatDate(item.startDate)} s/d ${_formatDate(item.endDate)}',
                                  style: TextStyle(
                                    fontSize: _largeTextMode ? 13 : 11,
                                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (item.spkNumber != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'SPK: ${item.spkNumber}',
                                    style: TextStyle(
                                      fontSize: _largeTextMode ? 13 : 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi SIP-K Dinsos Jatim?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final double nameFontSize = _largeTextMode ? 20 : 17;
    final double nipFontSize = _largeTextMode ? 14 : 12;
    final double roleFontSize = _largeTextMode ? 13 : 11;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          alignment: Alignment.centerLeft,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Profil Pegawai',
                  style: TextStyle(
                    fontSize: _largeTextMode ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Informasi akun & riwayat dinas',
                  style: TextStyle(
                    fontSize: _largeTextMode ? 13 : 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // KARTU PROFIL PEGAWAI + AVATAR DENGAN TOMBOL EDIT FOTO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF24487A), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF24487A).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFFF1F5F9),
                          backgroundImage: _profileImageUrl == null
                              ? null
                              : imageProviderFromSource(_profileImageUrl!),
                          child:
                              imageProviderFromSource(_profileImageUrl ?? '') ==
                                  null
                              ? _buildCurrentAvatar()
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showChangePhotoDialog(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userProfile.name,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIP. ${_userProfile.nip}',
                    style: TextStyle(
                      fontSize: nipFontSize,
                      color: Colors.white70,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_userProfile.position} • ${_userProfile.department}',
                    style: TextStyle(
                      fontSize: roleFontSize,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MENU PROFIL
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.account_circle_outlined,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF24487A),
                    title: 'Informasi Pengguna',
                    subtitle: 'Lihat nama, NIP, jabatan, dan bidang',
                    onTap: () async {
                      final updated = await Navigator.push<UserProfile>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserInformationScreen(
                            name: _userProfile.name,
                            nip: _userProfile.nip,
                            position: _userProfile.position,
                            department: _userProfile.department,
                            email: _userProfile.email,
                            phone: _userProfile.phone,
                            profileImageUrl: _userProfile.profileImageUrl,
                            onProfileUpdated: _updateProfile,
                          ),
                        ),
                      );
                      if (updated != null && mounted) {
                        _updateProfile(updated);
                      }
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 64,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    iconBg: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFDC2626),
                    title: 'Riwayat Pinjaman',
                    subtitle: 'Lihat semua riwayat pengajuan armada',
                    onTap: () => _showHistoryModal(context),
                  ),
                  Divider(
                    height: 1,
                    indent: 64,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    title: 'Pengaturan & Aksesibilitas',
                    subtitle: 'Preferensi notifikasi, font, & keamanan',
                    onTap: () => _showSettingsModal(context),
                  ),
                  Divider(
                    height: 1,
                    indent: 64,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    iconBg: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFDC2626),
                    title: 'Logout',
                    subtitle: 'Keluar dari aplikasi',
                    isDestructive: true,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SIP-K Dinsos Jatim v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = ThemeService.isDarkMode;
    final double titleSize = _largeTextMode ? 16 : 14;
    final double subtitleSize = _largeTextMode ? 13 : 11;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark && !isDestructive ? const Color(0xFF334155) : iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDark && !isDestructive ? const Color(0xFF60A5FA) : iconColor,
          size: _largeTextMode ? 24 : 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.bold,
          color: isDestructive
              ? const Color(0xFFDC2626)
              : (isDark ? Colors.white : const Color(0xFF1E293B)),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: subtitleSize,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      ),
    );
  }
}

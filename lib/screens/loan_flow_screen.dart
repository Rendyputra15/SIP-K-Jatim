import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/screens/loan_form_screen.dart';
import 'package:simodis_jatim/widgets/app_header_profile_avatar.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class LoanFlowScreen extends StatelessWidget {
  final List<Vehicle> vehicles;
  final Vehicle? preselectedVehicle;
  final Function(LoanRequest) onSubmitLoan;
  final Function(int)? onNavigateTab;

  const LoanFlowScreen({
    super.key,
    required this.vehicles,
    this.preselectedVehicle,
    required this.onSubmitLoan,
    this.onNavigateTab,
  });

  void _navigateToForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoanFormScreen(
          vehicles: vehicles,
          preselectedVehicle: preselectedVehicle,
          onSubmit: onSubmitLoan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Prosedur Peminjaman',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Panduan alur operasional armada dinas',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppHeaderProfileAvatar(
                  onTap: () => onNavigateTab?.call(4),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Prosedur
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF1E3A8A), Color(0xFF2563EB)]
                      : const [Color(0xFF24487A), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF24487A).withValues(alpha: isDark ? 0.4 : 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.alt_route_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alur Mudah & Transparan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ikuti 3 langkah mudah berikut untuk mengajukan permohonan pinjam armada dinas.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFF1F5F9),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Timeline Steps
            _buildTimelineStep(
              stepNumber: '1',
              title: 'Isi Formulir & Upload Nota',
              subtitle: 'Formulir Peminjaman & Softfile Nota Dinas',
              description: 'Lengkapi data peminjam, instansi/bidang, tanggal penggunaan, serta upload scan Nota Dinas resmi atau Surat Tugas.',
              icon: Icons.edit_note_rounded,
              iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
              badgeColor: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
              badgeText: 'Tahap 1',
              isLast: false,
              isDark: isDark,
            ),

            _buildTimelineStep(
              stepNumber: '2',
              title: 'Verifikasi Pengelola Aset',
              subtitle: 'Pengecekan Kasubag Umum & Aset',
              description: 'Tim pengelola aset Dinsos Jatim akan memverifikasi kesesuaian jadwal dan ketersediaan armada dalam waktu 1-3 jam jam kerja.',
              icon: Icons.verified_user_rounded,
              iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              badgeColor: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
              badgeText: 'Tahap 2',
              isLast: false,
              isDark: isDark,
            ),

            _buildTimelineStep(
              stepNumber: '3',
              title: 'Disetujui & Serah Terima',
              subtitle: 'Penerbitan SPK & Pengambilan Kunci',
              description: 'Setelah permohonan disetujui, nomor Surat Perintah Kerja (SPK) terbit secara otomatis. Pegawai dapat mengambil kunci kontak dan STNK asli di loket pengelola aset Gedung A Dinsos Jatim.',
              icon: Icons.check_circle_rounded,
              iconColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
              badgeColor: isDark ? const Color(0xFF166534) : const Color(0xFFDCFCE7),
              badgeText: 'Tahap Akhir',
              isLast: true,
              isDark: isDark,
            ),

            const SizedBox(height: 14),

            // Ketentuan Penggunaan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ketentuan Penggunaan Armada',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRequirementItem('Wajib memiliki SIM A / SIM C yang masih berlaku aktif.', isDark),
                  _buildRequirementItem('Nota Dinas / Surat Tugas harus ditandatangani Kepala Bidang.', isDark),
                  _buildRequirementItem('Wajib mengembalikan armada tepat waktu dan mengisi form BAST.', isDark),
                  _buildRequirementItem('Menjaga kebersihan dan memeriksa kondisi fisik unit saat selesai.', isDark),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _navigateToForm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF24487A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mulai Isi Formulir Peminjaman',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String stepNumber,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color badgeColor,
    required String badgeText,
    required bool isLast,
    required bool isDark,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2563EB) : const Color(0xFF24487A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? const Color(0xFF2563EB) : const Color(0xFF24487A))
                          .withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 18, color: iconColor),
                          const SizedBox(width: 6),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 13,
              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF334155),
                height: 1.3,
                fontWeight: isDark ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
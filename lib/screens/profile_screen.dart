import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/screens/loan_history_screen.dart';
import 'package:simodis_jatim/screens/login_screen.dart';
import 'package:simodis_jatim/widgets/nota_dinas_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final List<LoanRequest> loans;
  final Function(int) onNavigateTab;

  const ProfileScreen({
    super.key,
    required this.loans,
    required this.onNavigateTab,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State Pengaturan
  bool _notifStatusEnabled = true;
  bool _notifReminderEnabled = true;
  bool _largeTextMode = false; // Mode Aksesibilitas (Teks Besar)

  // State Foto Profil
  String? _profileImageUrl;

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // DIALOG GANTI FOTO PROFIL
  void _showChangePhotoDialog(BuildContext context) {
    final urlController = TextEditingController();

    final List<String> presetAvatars = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&q=80',
    ];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
                  const Text(
                    'Ganti Foto Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
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
                'Pilih foto karakter instansi atau masukkan tautan gambar baru:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),

              // Pilihan Avatar Cepat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: presetAvatars.map((avatarUrl) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _profileImageUrl = avatarUrl);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto profil berhasil diperbarui.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFF24487A),
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 14),

              // Input URL Mandiri
              TextField(
                controller: urlController,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'https://link-gambar.com/foto.jpg',
                  labelText: 'URL Gambar Kustom',
                  labelStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(Icons.link_rounded, size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(
                          () => _profileImageUrl = null,
                        ); // Reset ke inisial
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (urlController.text.trim().isNotEmpty) {
                          setState(
                            () => _profileImageUrl = urlController.text.trim(),
                          );
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24487A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Simpan',
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
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formPasswordKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.84,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pengaturan Akun & Aplikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sesuaikan preferensi tampilan, notifikasi, dan keamanan',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),

                // 1. AKSESIBILITAS TAMPILAN
                const Text(
                  'Aksesibilitas & Tampilan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    activeThumbColor: const Color(0xFF24487A),
                    title: const Text(
                      'Mode Teks Lebih Besar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Memperbesar ukuran font agar lebih mudah dibaca',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    value: _largeTextMode,
                    onChanged: (val) {
                      setModalState(() => _largeTextMode = val);
                      setState(() => _largeTextMode = val);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 2. PENGATURAN NOTIFIKASI
                const Text(
                  'Preferensi Notifikasi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        activeThumbColor: const Color(0xFF24487A),
                        title: const Text(
                          'Status Pengajuan & SPK',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Pemberitahuan persetujuan dan penolakan peminjaman',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        value: _notifStatusEnabled,
                        onChanged: (val) {
                          setModalState(() => _notifStatusEnabled = val);
                          setState(() => _notifStatusEnabled = val);
                        },
                      ),
                      const Divider(
                        height: 1,
                        indent: 14,
                        endIndent: 14,
                        color: Color(0xFFE2E8F0),
                      ),
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        activeThumbColor: const Color(0xFF24487A),
                        title: const Text(
                          'Pengingat Waktu Pengembalian',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Peringatan sebelum batas waktu dinas berakhir',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        value: _notifReminderEnabled,
                        onChanged: (val) {
                          setModalState(() => _notifReminderEnabled = val);
                          setState(() => _notifReminderEnabled = val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. KEAMANAN & UBAH PASSWORD
                const Text(
                  'Keamanan Akun',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Form(
                    key: formPasswordKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: oldPasswordController,
                          obscureText: true,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Password Saat Ini',
                            labelStyle: const TextStyle(fontSize: 12),
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Password lama wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: true,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Password Baru',
                            labelStyle: const TextStyle(fontSize: 12),
                            prefixIcon: const Icon(Icons.key_rounded, size: 18),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) => val != null && val.length < 6
                              ? 'Minimal 6 karakter'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              if (formPasswordKey.currentState!.validate()) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password akun dinas berhasil diperbarui.',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF24487A),
                              side: const BorderSide(color: Color(0xFF24487A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Perbarui Password',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // MODAL DETAIL POP-UP RIWAYAT PINJAMAN
  void _showLoanDetailDialog(BuildContext context, LoanRequest item) {
    Color statusBg;
    Color statusTextColor;
    String statusText;

    switch (item.status) {
      case LoanStatus.disetujui:
      case LoanStatus.approved:
        statusBg = const Color(0xFFDCFCE7);
        statusTextColor = const Color(0xFF15803D);
        statusText = 'DISETUJUI';
        break;
      case LoanStatus.ditolak:
      case LoanStatus.rejected:
        statusBg = const Color(0xFFFEE2E2);
        statusTextColor = const Color(0xFFB91C1C);
        statusText = 'DITOLAK';
        break;
      case LoanStatus.dibatalkan:
        statusBg = const Color(0xFFE2E8F0);
        statusTextColor = const Color(0xFF475569);
        statusText = 'DIBATALKAN';
        break;
      case LoanStatus.selesai:
        statusBg = const Color(0xFFEFF6FF);
        statusTextColor = const Color(0xFF1D4ED8);
        statusText = 'SELESAI';
        break;
      default:
        statusBg = const Color(0xFFFEF3C7);
        statusTextColor = const Color(0xFFB45309);
        statusText = 'MENUNGGU VERIFIKASI';
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
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
                        borderRadius: BorderRadius.circular(6),
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
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.vehicleName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
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
    final double labelSize = _largeTextMode ? 14 : 12;
    final double valueSize = _largeTextMode ? 14 : 12;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: _largeTextMode ? 18 : 16,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: _largeTextMode ? 120 : 105,
          child: Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        Text(
          ': ',
          style: TextStyle(fontSize: labelSize, color: const Color(0xFF64748B)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  void _showHistoryModal(BuildContext context) {
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: const Color(0xFFCBD5E1),
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
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ketuk pada salah satu kartu untuk melihat detail lengkap',
              style: TextStyle(
                fontSize: _largeTextMode ? 13 : 11,
                color: const Color(0xFF64748B),
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
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
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
                                          color: const Color(0xFF1E293B),
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
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Jadwal: ${_formatDate(item.startDate)} s/d ${_formatDate(item.endDate)}',
                                  style: TextStyle(
                                    fontSize: _largeTextMode ? 13 : 11,
                                    color: const Color(0xFF0369A1),
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
                                      color: const Color(0xFF24487A),
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
    final double nameFontSize = _largeTextMode ? 20 : 17;
    final double nipFontSize = _largeTextMode ? 14 : 12;
    final double roleFontSize = _largeTextMode ? 13 : 11;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: const Color(0xFFF1F5F9),
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
                    color: const Color(0xFF1E293B),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Informasi akun & riwayat dinas',
                  style: TextStyle(
                    fontSize: _largeTextMode ? 13 : 11,
                    color: const Color(0xFF64748B),
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
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                          onBackgroundImageError: _profileImageUrl != null
                              ? (exception, stackTrace) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      setState(() => _profileImageUrl = null);
                                    }
                                  });
                                }
                              : null,
                          child: _profileImageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 42,
                                  color: Color(0xFF24487A),
                                )
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
                    'Rendy Cahyono Putra',
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIP. 199503152020121002',
                    style: TextStyle(
                      fontSize: nipFontSize,
                      color: Colors.white70,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Staf Pelaksana • Dinas Sosial Jawa Timur',
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    iconBg: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFDC2626),
                    title: 'Riwayat Pinjaman',
                    subtitle: 'Lihat semua riwayat pengajuan armada',
                    onTap: () => _showHistoryModal(context),
                  ),
                  const Divider(
                    height: 1,
                    indent: 64,
                    color: Color(0xFFF1F5F9),
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    title: 'Pengaturan & Aksesibilitas',
                    subtitle: 'Preferensi notifikasi, font, & keamanan',
                    onTap: () => _showSettingsModal(context),
                  ),
                  const Divider(
                    height: 1,
                    indent: 64,
                    color: Color(0xFFF1F5F9),
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
    final double titleSize = _largeTextMode ? 16 : 14;
    final double subtitleSize = _largeTextMode ? 13 : 11;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: _largeTextMode ? 24 : 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.bold,
          color: isDestructive
              ? const Color(0xFFDC2626)
              : const Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: subtitleSize,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}

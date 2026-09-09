import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';

class LoanDetailDialog {
  static void show(
    BuildContext context, {
    required LoanRequest loan,
    required Function(LoanRequest, bool) onVerify,
  }) {
    final durationDays = loan.endDate.difference(loan.startDate).inDays + 1;
    final isPending =
        loan.status == LoanStatus.menunggu || loan.status == LoanStatus.pending;

    String formatDate(DateTime d) {
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    String formatDateTimeFull(DateTime d) {
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} Pukul ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} WIB';
    }

    Widget buildPopupDetailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ),
            const Text(
              ': ',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      );
    }

    void showConfirmApproval(
      BuildContext context,
      LoanRequest loan,
      bool approve,
    ) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            approve ? 'Konfirmasi Terbitkan Nota Dinas?' : 'Tolak Permohonan?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  approve
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
            ),
          ),
          content: Text(
            approve
                ? 'Sistem akan otomatis mengirimkan Softfile Nota Dinas resmi ke akun pemohon ${loan.borrowerName} untuk dicetak.'
                : 'Permohonan peminjaman armada oleh ${loan.borrowerName} akan ditolak.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onVerify(loan, approve);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      approve
                          ? 'Permohonan disetujui. Softfile Nota Dinas otomatis dikirim ke akun pemohon.'
                          : 'Permohonan telah ditolak.',
                    ),
                    backgroundColor:
                        approve
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    approve
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: Text(approve ? 'Ya, Terbitkan' : 'Ya, Tolak'),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 24,
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Dialog
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detail Pengajuan Peminjaman',
                      style: TextStyle(
                        fontSize: 15,
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
                const SizedBox(height: 4),
                Text(
                  'ID Registrasi: ${loan.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'monospace',
                  ),
                ),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),

                // Informasi Waktu Masuk Sistem (Jam & Menit)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        size: 20,
                        color: Color(0xFF24487A),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Waktu Pengajuan Diterima:',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              formatDateTimeFull(loan.submittedAt),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Data Pemohon & Kendaraan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 8),
                buildPopupDetailRow('Nama Pemohon', loan.borrowerName),
                buildPopupDetailRow(
                  'Unit Kerja / Bidang',
                  loan.department.isEmpty
                      ? 'Dinas Sosial Jatim'
                      : loan.department,
                ),
                buildPopupDetailRow('Armada Diajukan', loan.vehicleName),
                buildPopupDetailRow(
                  'Jadwal Tugas',
                  '${formatDate(loan.startDate)} s/d ${formatDate(loan.endDate)} ($durationDays Hari Kerja)',
                ),

                const SizedBox(height: 14),
                const Text(
                  'Rincian Penugasan Dinas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 8),
                buildPopupDetailRow('Tujuan Dinas', loan.destination),
                buildPopupDetailRow(
                  'Alamat Lengkap',
                  loan.destinationAddress.isEmpty
                      ? 'Area Kota / UPT Terkait'
                      : loan.destinationAddress,
                ),
                buildPopupDetailRow(
                  'Deskripsi Keperluan',
                  loan.purposeDescription.isEmpty
                      ? '-'
                      : loan.purposeDescription,
                ),
                buildPopupDetailRow(
                  'Nomor Nota Dinas',
                  loan.officialNoteNumber.isEmpty
                      ? '-'
                      : loan.officialNoteNumber,
                ),
                buildPopupDetailRow(
                  'Surat Usulan Bidang',
                  'Terlampir & Tervalidasi E-Office',
                ),

                if (loan.spkNumber != null) ...[
                  const SizedBox(height: 8),
                  buildPopupDetailRow(
                    'No. Terbit Nota Dinas',
                    loan.spkNumber!,
                  ),
                ],

                const SizedBox(height: 20),

                // TOMBOL ATAS-BAWAH HANYA MUNCUL JIKA STATUS MASIH MENUNGGU
                if (isPending) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        showConfirmApproval(context, loan, true);
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text(
                        'Setujui & Terbitkan Nota Dinas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        showConfirmApproval(context, loan, false);
                      },
                      icon: const Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: Color(0xFFDC2626),
                      ),
                      label: const Text(
                        'Tolak Permohonan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

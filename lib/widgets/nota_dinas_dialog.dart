import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';

class NotaDinasDialog extends StatelessWidget {
  final LoanRequest loan;

  const NotaDinasDialog({super.key, required this.loan});

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final regNumber = loan.spkNumber ?? 'ND-0901/DINSOS/${DateTime.now().year}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Dialog (Tombol Tutup)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Softfile Lembar Nota Dinas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
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
              const SizedBox(height: 14),

              // AREA KERTAS DOKUMEN CETAK (BORDER GREY SEPERTI SELEMBAR SURAT)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KOP SURAT PEMERINTAH PROVINSI JAWA TIMUR
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'PEMERINTAH PROVINSI JAWA TIMUR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Text(
                            'DINAS SOSIAL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const Text(
                            'Jl. Gayung Kebonsari No.56, Surabaya, Jawa Timur 60235',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(height: 2, color: Colors.black),
                          const SizedBox(height: 2),
                          Container(height: 0.8, color: Colors.black),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // JUDUL NOTA DINAS
                    const Center(
                      child: Text(
                        'NOTA DINAS / IZIN PENGGUNAAN KENDARAAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Nomor: $regNumber',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF334155),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ISI SURAT KEDINASAN
                    _buildRowText(
                      'Kepada',
                      'Kasubag Tata Usaha & Pengelola Kendaraan',
                    ),
                    _buildRowText(
                      'Dari',
                      loan.department.isEmpty
                          ? 'Staf Pemohon Dinas'
                          : loan.department,
                    ),
                    _buildRowText(
                      'Tanggal Terbit',
                      _formatDate(DateTime.now()),
                    ),
                    _buildRowText(
                      'Perihal',
                      'Izin Pemakaian Kendaraan Operasional Dinas',
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 10),

                    const Text(
                      'Diberikan persetujuan pemakaian armada dinas dengan rincian data sebagai berikut:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color.fromARGB(255, 51, 77, 85),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildFieldBox(
                      'Nama Pemohon / Pengemudi',
                      loan.borrowerName,
                    ),
                    _buildFieldBox('Armada Kendaraan', loan.vehicleName),
                    _buildFieldBox(
                      'Jadwal Pelaksanaan Tugas',
                      '${_formatDate(loan.startDate)} s/d ${_formatDate(loan.endDate)}',
                    ),
                    _buildFieldBox('Tujuan Dinas', loan.destination),
                    if (loan.destinationAddress.isNotEmpty)
                      _buildFieldBox(
                        'Alamat Lokasi Tujuan',
                        loan.destinationAddress,
                      ),
                    _buildFieldBox(
                      'Status Verifikasi',
                      'DISETUJUI / DISAHKAN OLEH KASUBAG UMUM',
                    ),

                    const SizedBox(height: 16),

                    // TANDA TANGAN ELEKTRONIK / STEMPEL VALIDASI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Barcode verifikasi digital
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.qr_code_2_rounded,
                                size: 48,
                                color: Color(0xFF1E293B),
                              ),
                              Text(
                                'Validasi SIP-K',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Blok Tanda Tangan Kasubag
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Surabaya, Kasubag Umum',
                              style: TextStyle(fontSize: 10),
                            ),
                            SizedBox(height: 34), // Ruang Tanda Tangan
                            Text(
                              'Drs. H. PENGELOLA ASET, M.Si',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Text(
                              'NIP. 19780512 200501 1 004',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // TOMBOL AKSI CETAK & UNDUH DOKUMEN
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Berkas softfile Nota Dinas disimpan ke folder Unduhan (PDF).',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF24487A),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text(
                        'Unduh PDF',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF24487A),
                        side: const BorderSide(color: Color(0xFF24487A)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Mengirim dokumen ke printer kantor... Silakan serahkan cetakan ke Kasubag TU.',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF16A34A),
                          ),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text(
                        'Cetak Berkas',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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

  Widget _buildRowText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF475569)),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 10, color: Color(0xFF475569)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldBox(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              '• $label',
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          Expanded(
            child: Text(
              val,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

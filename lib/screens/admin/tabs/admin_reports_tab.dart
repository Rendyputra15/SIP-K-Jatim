import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';

class AdminReportsTab extends StatefulWidget {
  final List<LoanRequest> requests;
  final List<Vehicle> vehicles;
  final List<AppUser> users;

  const AdminReportsTab({
    super.key,
    required this.requests,
    required this.vehicles,
    required this.users,
  });

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  String _selectedPeriod = 'Bulan Ini (September 2026)';
  String _searchQuery = '';

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void _showExportSuccessDialog(String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
            size: 32,
          ),
        ),
        title: Text(
          'Ekspor $type Berhasil',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Dokumen laporan rekapitulasi peminjaman armada dinas periode $_selectedPeriod siap diunduh.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24487A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedLoans = widget.requests
        .where(
          (r) =>
              r.status == LoanStatus.selesai ||
              r.status == LoanStatus.disetujui ||
              r.status == LoanStatus.approved,
        )
        .toList();

    final filteredRequests = widget.requests.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.borrowerName.toLowerCase().contains(q) ||
          r.vehicleName.toLowerCase().contains(q) ||
          r.destination.toLowerCase().contains(q) ||
          r.department.toLowerCase().contains(q);
    }).toList();

    // Hitung bidang terbanyak
    final deptCount = <String, int>{};
    for (final r in widget.requests) {
      final dept = r.department.isNotEmpty ? r.department : 'Dinsos Jatim';
      deptCount[dept] = (deptCount[dept] ?? 0) + 1;
    }
    String topDept = deptCount.isNotEmpty
        ? (deptCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key
        : '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Tombol Aksi Ekspor
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                color: Color(0xFF24487A),
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Laporan & Rekapitulasi Dinas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Rekap utilisasi armada dan pertanggungjawaban aset kendaraan Dinsos Jatim.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Dropdown Periode
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF24487A),
                          ),
                          items: [
                            'Bulan Ini (September 2026)',
                            'Bulan Lalu (Agustus 2026)',
                            'Triwulan 3 (2026)',
                            'Tahun 2026 Penuh',
                          ]
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedPeriod = v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),

                // Tombol Ekspor
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showExportSuccessDialog('PDF'),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                      label: const Text(
                        'Cetak / Unduh PDF',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showExportSuccessDialog('Excel (XLSX)'),
                      icon: const Icon(Icons.table_view_rounded, size: 16),
                      label: const Text(
                        'Ekspor Excel (XLSX)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2. Metrik Rekap Ringkas
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _buildReportMetricCard(
                  'Total Permohonan',
                  widget.requests.length.toString(),
                  'Seluruh permohonan',
                  Icons.assignment_rounded,
                  const Color(0xFF2563EB),
                ),
                _buildReportMetricCard(
                  'Tuntas / Disetujui',
                  completedLoans.length.toString(),
                  'Armada bertugas',
                  Icons.check_circle_rounded,
                  const Color(0xFF16A34A),
                ),
                _buildReportMetricCard(
                  'Total Armada Aktif',
                  widget.vehicles.length.toString(),
                  'Mobil & Motor pool',
                  Icons.directions_car_rounded,
                  const Color(0xFFF59E0B),
                ),
                _buildReportMetricCard(
                  'Bidang Teraktif',
                  topDept.length > 15 ? '${topDept.substring(0, 14)}...' : topDept,
                  'Peminjam terbanyak',
                  Icons.apartment_rounded,
                  const Color(0xFF8B5CF6),
                ),
              ];

              return constraints.maxWidth < 600
                  ? Column(
                      children: cards
                          .map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: c))
                          .toList(),
                    )
                  : Row(
                      children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c))).toList(),
                    );
            },
          ),
          const SizedBox(height: 20),

          // 3. Ringkasan Utilisasi Armada
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tingkat Utilisasi Armada',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Frekuensi Peminjaman',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final v in widget.vehicles) ...[
                  _buildVehicleUsageRow(v),
                  if (v != widget.vehicles.last) const Divider(height: 16, color: Color(0xFFF1F5F9)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Tabel / Riwayat Log Terperinci
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Berkas Peminjaman Terdata',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '${filteredRequests.length} Data',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF24487A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Pencarian dalam laporan
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Cari nama pemohon, armada, tujuan, atau bidang...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                if (filteredRequests.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Tidak ada data laporan yang cocok dengan pencarian.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  )
                else
                  for (final item in filteredRequests) ...[
                    _buildReportItemRow(item),
                    if (item != filteredRequests.last)
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportMetricCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleUsageRow(Vehicle v) {
    // Hitung berapa kali dipinjam
    final loanCount = widget.requests.where((r) => r.vehicleName.contains(v.name)).length;
    final progress = (loanCount / (widget.requests.isEmpty ? 1 : widget.requests.length)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${v.name} (${v.plateNumber})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$loanCount Penugasan',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF24487A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress == 0 ? 0.05 : progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.4 ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportItemRow(LoanRequest item) {
    Color badgeColor;
    String statusLabel;
    switch (item.status) {
      case LoanStatus.disetujui:
      case LoanStatus.approved:
        badgeColor = const Color(0xFF16A34A);
        statusLabel = 'Disetujui';
        break;
      case LoanStatus.selesai:
        badgeColor = const Color(0xFF2563EB);
        statusLabel = 'Selesai (BAST)';
        break;
      case LoanStatus.ditolak:
      case LoanStatus.rejected:
        badgeColor = const Color(0xFFDC2626);
        statusLabel = 'Ditolak';
        break;
      default:
        badgeColor = const Color(0xFFF59E0B);
        statusLabel = 'Menunggu';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Color(0xFF24487A),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.borrowerName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${item.vehicleName} • ${item.department}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              Text(
                'Tujuan: ${item.destination} (${_formatDate(item.startDate)} - ${_formatDate(item.endDate)})',
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

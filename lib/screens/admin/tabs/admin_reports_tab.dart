import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/services/report_export_service.dart';

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
  String _selectedStatusFilter = 'Semua';
  bool _isExportingPdf = false;
  bool _isExportingExcel = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _exportPdf() async {
    setState(() => _isExportingPdf = true);
    try {
      await ReportExportService.exportPdf(
        requests: widget.requests,
        vehicles: widget.vehicles,
        period: _selectedPeriod,
      );
      if (mounted) _showExportDoneSnackbar('PDF');
    } catch (e) {
      if (mounted) _showExportErrorSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  Future<void> _exportExcel() async {
    setState(() => _isExportingExcel = true);
    try {
      await ReportExportService.exportExcel(
        requests: widget.requests,
        vehicles: widget.vehicles,
        period: _selectedPeriod,
      );
      if (mounted) _showExportDoneSnackbar('Excel (XLSX)');
    } catch (e) {
      if (mounted) _showExportErrorSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => _isExportingExcel = false);
    }
  }

  void _showExportDoneSnackbar(String type) {
    final isPdf = type.contains('PDF');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isPdf ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.table_chart_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Berhasil diunduh!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'File $type laporan armada siap. Cek folder Unduhan.',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  void _showExportErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFEF4444),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Gagal mengekspor: $error',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailBottomSheet(LoanRequest item) {
    Color badgeColor;
    String statusLabel;
    IconData statusIcon;

    switch (item.status) {
      case LoanStatus.disetujui:
      case LoanStatus.approved:
        badgeColor = const Color(0xFF10B981);
        statusLabel = 'Disetujui (Aktif)';
        statusIcon = Icons.check_circle_rounded;
        break;
      case LoanStatus.selesai:
        badgeColor = const Color(0xFF2563EB);
        statusLabel = 'Selesai (BAST)';
        statusIcon = Icons.task_alt_rounded;
        break;
      case LoanStatus.ditolak:
      case LoanStatus.rejected:
        badgeColor = const Color(0xFFEF4444);
        statusLabel = 'Ditolak';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        badgeColor = const Color(0xFFF59E0B);
        statusLabel = 'Menunggu Persetujuan';
        statusIcon = Icons.pending_rounded;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Berkas Laporan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: badgeColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildDetailItem(Icons.person_rounded, 'Nama Pemohon', item.borrowerName),
              _buildDetailItem(Icons.apartment_rounded, 'Bidang / Unit Kerja', item.department),
              _buildDetailItem(Icons.directions_car_rounded, 'Armada Ditugaskan', item.vehicleName),
              _buildDetailItem(Icons.location_on_rounded, 'Tujuan Penugasan', item.destination),
              if (item.destinationAddress.isNotEmpty)
                _buildDetailItem(Icons.map_rounded, 'Alamat Lengkap', item.destinationAddress),
              _buildDetailItem(
                Icons.calendar_today_rounded,
                'Periode Peminjaman',
                '${_formatDate(item.startDate)} s/d ${_formatDate(item.endDate)}',
              ),
              if (item.purposeDescription.isNotEmpty)
                _buildDetailItem(Icons.notes_rounded, 'Keperluan Dinas', item.purposeDescription),
              _buildDetailItem(
                Icons.assignment_rounded,
                'Nomor Nota Dinas',
                item.officialNoteNumber.isNotEmpty ? item.officialNoteNumber : '-',
              ),
              if (item.spkNumber != null && item.spkNumber!.isNotEmpty)
                _buildDetailItem(Icons.badge_rounded, 'Nomor SPK Terbit', item.spkNumber!),
              if (item.returnOdometer != null || item.returnFuel != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.assignment_turned_in_rounded, size: 16, color: Color(0xFF16A34A)),
                          SizedBox(width: 6),
                          Text(
                            'Data Pengembalian Unit (BAST)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Odometer Kembali: ${item.returnOdometer ?? "-"} km',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                      ),
                      Text(
                        '• Sisa BBM: ${item.returnFuel ?? "-"}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                      ),
                      if (item.returnNotes != null && item.returnNotes!.isNotEmpty)
                        Text(
                          '• Catatan BAST: ${item.returnNotes}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Tutup Detail', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF24487A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
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

    // Hitung bidang terbanyak
    final deptCount = <String, int>{};
    for (final r in widget.requests) {
      final dept = r.department.isNotEmpty ? r.department : 'Dinsos Jatim';
      deptCount[dept] = (deptCount[dept] ?? 0) + 1;
    }
    String topDept = deptCount.isNotEmpty
        ? (deptCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key
        : '-';

    final filteredRequests = widget.requests.where((r) {
      // Filter status
      if (_selectedStatusFilter == 'Disetujui' &&
          r.status != LoanStatus.disetujui &&
          r.status != LoanStatus.approved) {
        return false;
      }
      if (_selectedStatusFilter == 'Selesai' && r.status != LoanStatus.selesai) {
        return false;
      }
      if (_selectedStatusFilter == 'Menunggu' &&
          r.status != LoanStatus.menunggu &&
          r.status != LoanStatus.pending) {
        return false;
      }
      if (_selectedStatusFilter == 'Ditolak' &&
          r.status != LoanStatus.ditolak &&
          r.status != LoanStatus.rejected) {
        return false;
      }

      // Filter search
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.borrowerName.toLowerCase().contains(q) ||
          r.vehicleName.toLowerCase().contains(q) ||
          r.destination.toLowerCase().contains(q) ||
          r.department.toLowerCase().contains(q) ||
          (r.spkNumber != null && r.spkNumber!.toLowerCase().contains(q));
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HERO BANNER EXECUTIVE
          _buildExecutiveHeroBanner(),
          const SizedBox(height: 18),

          // 2. METRIC CARDS (GRID 2x2)
          _buildMetricsGrid(completedLoans.length, topDept),
          const SizedBox(height: 20),

          // 3. ARMADA UTILISASI CARD
          _buildFleetUtilizationCard(),
          const SizedBox(height: 20),

          // 4. LOG & ARSIP BERKAS PEMINJAMAN
          _buildLogAndArchiveSection(filteredRequests),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // === 1. EXECUTIVE HERO BANNER ===
  Widget _buildExecutiveHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2042), Color(0xFF1E3A5F), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circle
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -35,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Resmi Pemprov
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_rounded, color: Color(0xFFFCD34D), size: 13),
                      SizedBox(width: 5),
                      Text(
                        'SIP-K EKSEKUTIF • DINSOS PROV. JAWA TIMUR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Laporan & Rekapitulasi Operasional',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Monitoring utilisasi armada dinas, kepatuhan BAST, dan histori penugasan.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFE2E8F0),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // Baris Dropdown Periode (Dengan Background Card Putih)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range_rounded, size: 16, color: Color(0xFF24487A)),
                      const SizedBox(width: 8),
                      const Text(
                        'Periode:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPeriod,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF24487A), size: 18),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E3A5F),
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
                                    child: Text(p, overflow: TextOverflow.ellipsis),
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
                ),
                const SizedBox(height: 14),

                // Tombol Aksi Ekspor Cepat
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isExportingPdf ? null : _exportPdf,
                        icon: _isExportingPdf
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf_rounded, size: 15),
                        label: Text(
                          _isExportingPdf ? 'Memproses...' : 'Cetak PDF',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.6),
                          disabledForegroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isExportingExcel ? null : _exportExcel,
                        icon: _isExportingExcel
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.table_view_rounded, size: 15),
                        label: Text(
                          _isExportingExcel ? 'Memproses...' : 'Ekspor Excel',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF10B981).withValues(alpha: 0.6),
                          disabledForegroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === 2. METRICS KPI GRID ===
  Widget _buildMetricsGrid(int completedCount, String topDept) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Indikator Utama Laporan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Performa Periode Ini',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Total Permohonan',
                value: widget.requests.length.toString(),
                badge: 'Semua Berkas',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF2563EB),
                bgTint: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Disetujui & Tuntas',
                value: completedCount.toString(),
                badge: 'Terselesaikan',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF10B981),
                bgTint: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Total Armada Pool',
                value: '${widget.vehicles.length} Unit',
                badge: 'Mobil & Motor',
                icon: Icons.directions_car_filled_rounded,
                color: const Color(0xFFF59E0B),
                bgTint: const Color(0xFFFFFBEB),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Bidang Teraktif',
                value: topDept.length > 12 ? '${topDept.substring(0, 11)}...' : topDept,
                badge: 'Peminjam Terbanyak',
                icon: Icons.apartment_rounded,
                color: const Color(0xFF8B5CF6),
                bgTint: const Color(0xFFF5F3FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String badge,
    required IconData icon,
    required Color color,
    required Color bgTint,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: bgTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: bgTint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // === 3. FLEET UTILIZATION CARD ===
  Widget _buildFleetUtilizationCard() {
    int totalLoans = widget.requests.isEmpty ? 1 : widget.requests.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.speed_rounded, color: Color(0xFF24487A), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tingkat Utilisasi Armada',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.vehicles.length} Unit Pool',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Rasio frekuensi penugasan armada dinas selama periode terpilih.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),

          // List Kendaraan
          for (final v in widget.vehicles) ...[
            _buildVehicleUtilizationItem(v, totalLoans),
            if (v != widget.vehicles.last)
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleUtilizationItem(Vehicle v, int totalLoans) {
    final loanCount = widget.requests.where((r) => r.vehicleName.contains(v.name)).length;
    final percentage = ((loanCount / totalLoans) * 100).round();
    final progressVal = (loanCount / totalLoans).clamp(0.0, 1.0);

    Color progressColor;
    if (progressVal >= 0.4) {
      progressColor = const Color(0xFF10B981);
    } else if (progressVal >= 0.2) {
      progressColor = const Color(0xFF2563EB);
    } else {
      progressColor = const Color(0xFF64748B);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: v.type == VehicleType.motor
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                v.type == VehicleType.motor
                    ? Icons.two_wheeler_rounded
                    : Icons.directions_car_rounded,
                size: 16,
                color: v.type == VehicleType.motor
                    ? const Color(0xFFD97706)
                    : const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          v.plateNumber,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${v.transmission} • ${v.capacity} Seat',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$loanCount Tugas',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressVal == 0 ? 0.04 : progressVal,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  // === 4. LOG & ARCHIVE SECTION ===
  Widget _buildLogAndArchiveSection(List<LoanRequest> filteredRequests) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2_rounded, color: Color(0xFF24487A), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Arsip Berkas Permohonan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${filteredRequests.length} Berkas',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Cari nama, armada, tujuan, atau SPK...',
              hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Status Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua'),
                _buildFilterChip('Disetujui'),
                _buildFilterChip('Selesai'),
                _buildFilterChip('Menunggu'),
                _buildFilterChip('Ditolak'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // List Data Laporan
          if (filteredRequests.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 42, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const Text(
                    'Tidak ada berkas yang sesuai filter',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Coba ubah kata kunci pencarian atau ganti status filter di atas.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            )
          else
            for (final item in filteredRequests) ...[
              _buildReportCardItem(item),
              if (item != filteredRequests.last)
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
            ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedStatusFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedStatusFilter = label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCardItem(LoanRequest item) {
    Color badgeColor;
    String statusLabel;
    IconData statusIcon;

    switch (item.status) {
      case LoanStatus.disetujui:
      case LoanStatus.approved:
        badgeColor = const Color(0xFF10B981);
        statusLabel = 'Disetujui';
        statusIcon = Icons.check_circle_rounded;
        break;
      case LoanStatus.selesai:
        badgeColor = const Color(0xFF2563EB);
        statusLabel = 'Selesai BAST';
        statusIcon = Icons.task_alt_rounded;
        break;
      case LoanStatus.ditolak:
      case LoanStatus.rejected:
        badgeColor = const Color(0xFFEF4444);
        statusLabel = 'Ditolak';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        badgeColor = const Color(0xFFF59E0B);
        statusLabel = 'Menunggu';
        statusIcon = Icons.pending_rounded;
    }

    final initials = item.borrowerName.isNotEmpty
        ? item.borrowerName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'U';

    return InkWell(
      onTap: () => _showDetailBottomSheet(item),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF24487A).withValues(alpha: 0.1),
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF24487A),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Content
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
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 10, color: badgeColor),
                            const SizedBox(width: 3),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.vehicleName} • ${item.department}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${item.destination} (${_formatDate(item.startDate)} - ${_formatDate(item.endDate)})',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (item.spkNumber != null && item.spkNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'SPK: ${item.spkNumber}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF24487A),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

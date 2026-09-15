import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class LoanHistoryScreen extends StatefulWidget {
  final List<LoanRequest> loans;
  final ValueChanged<LoanRequest>? onLoanTap;
  final ValueChanged<LoanRequest>? onLoanCancelled;
  final ValueChanged<LoanRequest>? onLoanCompleted;
  final ValueChanged<LoanRequest>? onLoanStarted;

  const LoanHistoryScreen({
    super.key,
    required this.loans,
    this.onLoanTap,
    this.onLoanCancelled,
    this.onLoanCompleted,
    this.onLoanStarted,
  });

  @override
  State<LoanHistoryScreen> createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends State<LoanHistoryScreen> {
  DateTime? _selectedMonth;

  static const _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  bool _isWaiting(LoanStatus status) =>
      status == LoanStatus.menunggu || status == LoanStatus.pending;

  bool _isApproved(LoanStatus status) =>
      status == LoanStatus.disetujui || status == LoanStatus.approved;

  bool _isInUse(LoanStatus status) =>
      status == LoanStatus.digunakan;

  String _monthLabel(DateTime month) =>
      '${_monthNames[month.month - 1]} ${month.year}';

  List<DateTime> get _availableMonths {
    final months = <String, DateTime>{};
    for (final loan in widget.loans) {
      final month = DateTime(loan.startDate.year, loan.startDate.month);
      months['${month.year}-${month.month}'] = month;
    }
    final result = months.values.toList()..sort((a, b) => b.compareTo(a));
    return result;
  }

  bool _matchesSelectedMonth(LoanRequest loan) {
    final selectedMonth = _selectedMonth;
    return selectedMonth == null ||
        (loan.startDate.year == selectedMonth.year &&
            loan.startDate.month == selectedMonth.month);
  }

  List<LoanRequest> _loansForTab(int tabIndex) {
    final filteredLoans = widget.loans.where((loan) {
      if (!_matchesSelectedMonth(loan)) return false;
      switch (tabIndex) {
        case 0:
          return _isWaiting(loan.status);
        case 1:
          return _isApproved(loan.status);
        case 2:
          return _isInUse(loan.status);
        case 3:
          return loan.status == LoanStatus.selesai;
        case 4:
          return loan.status == LoanStatus.ditolak ||
              loan.status == LoanStatus.rejected;
        default:
          return loan.status == LoanStatus.dibatalkan;
      }
    }).toList();

    filteredLoans.sort(
      (first, second) => second.submittedAt.compareTo(first.submittedAt),
    );
    return filteredLoans;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
          elevation: 0,
          title: const Text(
            'Riwayat Peminjaman',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            indicatorColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
            tabs: const [
              Tab(text: 'Menunggu'),
              Tab(text: 'Disetujui'),
              Tab(text: 'Digunakan'),
              Tab(text: 'Selesai'),
              Tab(text: 'Ditolak'),
              Tab(text: 'Dibatalkan'),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Text(
                'Pantau status seluruh pengajuan kendaraan dinas Anda.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: DropdownButtonFormField<DateTime?>(
                initialValue: _selectedMonth,
                isDense: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  labelText: 'Filter bulan peminjaman',
                  labelStyle: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  prefixIcon: Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                items: [
                  DropdownMenuItem<DateTime?>(
                    value: null,
                    child: Text(
                      'Semua bulan',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                  ),
                  ..._availableMonths.map(
                    (month) => DropdownMenuItem<DateTime?>(
                      value: month,
                      child: Text(
                        _monthLabel(month),
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                      ),
                    ),
                  ),
                ],
                onChanged: (month) => setState(() => _selectedMonth = month),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLoanList(0),
                  _buildLoanList(1),
                  _buildLoanList(2),
                  _buildLoanList(3),
                  _buildLoanList(4),
                  _buildLoanList(5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanList(int tabIndex) {
    final filteredLoans = _loansForTab(tabIndex);
    final isDark = ThemeService.isDarkMode;

    return RefreshIndicator(
      color: const Color(0xFF24487A),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 750));
        if (mounted) setState(() {});
      },
      child: filteredLoans.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tabIndex == 2
                            ? Icons.directions_car_outlined
                            : Icons.inbox_outlined,
                        size: 48,
                        color: isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tabIndex == 2
                            ? 'Tidak ada kendaraan yang sedang digunakan saat ini.'
                            : 'Belum ada pengajuan pada kategori ini.',
                        style: const TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: filteredLoans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final loan = filteredLoans[index];
                return _buildLoanCard(context, loan);
              },
            ),
    );
  }

  Widget _buildLoanCard(BuildContext context, LoanRequest loan) {
    final isDark = ThemeService.isDarkMode;
    final isApproved = _isApproved(loan.status);
    final isInUse = _isInUse(loan.status);
    final isCompleted = loan.status == LoanStatus.selesai;
    final isRejected =
        loan.status == LoanStatus.ditolak || loan.status == LoanStatus.rejected;
    final isCancelled = loan.status == LoanStatus.dibatalkan;

    final statusLabel = isInUse
        ? 'DIGUNAKAN'
        : isCompleted
        ? 'SELESAI'
        : isApproved
        ? 'DISETUJUI'
        : isRejected
        ? 'DITOLAK'
        : isCancelled
        ? 'DIBATALKAN'
        : 'MENUNGGU';

    final statusBackground = isInUse
        ? (isDark ? const Color(0xFF075985) : const Color(0xFFE0F2FE))
        : isCompleted
        ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE))
        : isApproved
        ? (isDark ? const Color(0xFF166534) : const Color(0xFFDCFCE7))
        : isRejected
        ? (isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2))
        : isCancelled
        ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
        : (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7));

    final statusForeground = isInUse
        ? (isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7))
        : isCompleted
        ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8))
        : isApproved
        ? (isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D))
        : isRejected
        ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C))
        : isCancelled
        ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))
        : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309));

    return InkWell(
      onTap: () {
        if (widget.onLoanTap != null) {
          widget.onLoanTap!(loan);
        } else {
          _showLoanDetailDialog(loan);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    loan.vehicleName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusForeground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Tujuan: ${loan.destination}',
              style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text(
              'Jadwal: ${_formatDate(loan.startDate)} s/d ${_formatDate(loan.endDate)}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (loan.spkNumber != null) ...[
              const SizedBox(height: 6),
              Text(
                'SPK: ${loan.spkNumber}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                ),
              ),
            ],

            // 1. TAMPILAN JIKA SEDANG DIGUNAKAN (FITUR SELESAIKAN PINJAMAN LEBIH AWAL)
            if (isInUse) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0C4A6E).withValues(alpha: 0.35)
                      : const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF0284C7).withValues(alpha: 0.5)
                        : const Color(0xFFBAE6FD),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_car_rounded,
                      size: 16,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Armada sedang beroperasi. Selesai lebih cepat? Selesaikan pinjaman sekarang.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCompleteLoanDialog(context, loan),
                  icon: const Icon(Icons.check_circle_rounded, size: 16),
                  label: const Text('Selesaikan Pinjaman'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],

            // 2. TAMPILAN JIKA DISETUJUI (OPSI MULAI GUNAKAN ARMADA)
            if (isApproved) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmStartUsingLoan(context, loan),
                  icon: const Icon(Icons.key_rounded, size: 16),
                  label: const Text('Mulai Gunakan Armada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],

            // 3. TAMPILAN JIKA MENUNGGU (OPSI BATALKAN PINJAMAN)
            if (_isWaiting(loan.status)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancellation(context, loan),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Batalkan Pinjaman'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB91C1C),
                    backgroundColor: const Color(0xFFFFF7F7),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLoanDetailDialog(LoanRequest loan) {
    final isApproved = _isApproved(loan.status);
    final isInUse = _isInUse(loan.status);
    final isCompleted = loan.status == LoanStatus.selesai;
    final isRejected =
        loan.status == LoanStatus.ditolak || loan.status == LoanStatus.rejected;
    final isCancelled = loan.status == LoanStatus.dibatalkan;

    final statusLabel = isInUse
        ? 'SEDANG DIGUNAKAN'
        : isCompleted
        ? 'SELESAI'
        : isApproved
        ? 'DISETUJUI'
        : isRejected
        ? 'DITOLAK'
        : isCancelled
        ? 'DIBATALKAN'
        : 'MENUNGGU VERIFIKASI';

    final isDarkDialog = ThemeService.isDarkMode;
    final statusColor = isInUse
        ? (isDarkDialog ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7))
        : isCompleted
        ? (isDarkDialog ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8))
        : isApproved
        ? (isDarkDialog ? const Color(0xFF86EFAC) : const Color(0xFF15803D))
        : isRejected
        ? (isDarkDialog ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C))
        : isCancelled
        ? (isDarkDialog ? const Color(0xFF94A3B8) : const Color(0xFF475569))
        : (isDarkDialog ? const Color(0xFFFBBF24) : const Color(0xFFB45309));

    final statusBackground = isInUse
        ? (isDarkDialog ? const Color(0xFF075985) : const Color(0xFFE0F2FE))
        : isCompleted
        ? (isDarkDialog ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE))
        : isApproved
        ? (isDarkDialog ? const Color(0xFF166534) : const Color(0xFFDCFCE7))
        : isRejected
        ? (isDarkDialog ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2))
        : isCancelled
        ? (isDarkDialog ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
        : (isDarkDialog ? const Color(0xFF78350F) : const Color(0xFFFEF3C7));

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Theme(
        data: isDarkDialog ? ThemeService.darkTheme : ThemeService.lightTheme,
        child: Dialog(
          backgroundColor: isDarkDialog ? const Color(0xFF1E293B) : Colors.white,
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
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded),
                        color: isDarkDialog ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loan.vehicleName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkDialog ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ID Permohonan: #${loan.id.length > 8 ? loan.id.substring(loan.id.length - 8) : loan.id}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkDialog ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: isDarkDialog ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    Icons.person_outline_rounded,
                    'Peminjam',
                    loan.borrowerName,
                  ),
                  _buildDetailRow(
                    Icons.business_rounded,
                    'Bidang / Seksi',
                    loan.department,
                  ),
                  _buildDetailRow(
                    Icons.calendar_month_rounded,
                    'Jadwal Tugas',
                    '${_formatDate(loan.startDate)} - ${_formatDate(loan.endDate)}',
                  ),
                  _buildDetailRow(
                    Icons.near_me_rounded,
                    'Tujuan Instansi',
                    loan.destination,
                  ),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Alamat Tujuan',
                    loan.destinationAddress.isEmpty
                        ? '-'
                        : loan.destinationAddress,
                  ),
                  _buildDetailRow(
                    Icons.description_outlined,
                    'Keperluan Dinas',
                    loan.purposeDescription.isEmpty
                        ? '-'
                        : loan.purposeDescription,
                  ),
                  if (loan.spkNumber != null)
                    _buildDetailRow(
                      Icons.badge_outlined,
                      'Nomor SPK',
                      loan.spkNumber!,
                    ),
                  if (loan.returnOdometer != null)
                    _buildDetailRow(
                      Icons.speed_rounded,
                      'Odometer Akhir',
                      '${loan.returnOdometer} KM',
                    ),
                  if (loan.returnFuel != null)
                    _buildDetailRow(
                      Icons.local_gas_station_rounded,
                      'Sisa BBM',
                      '${loan.returnFuel}',
                    ),
                  if (loan.returnNotes != null && loan.returnNotes!.isNotEmpty)
                    _buildDetailRow(
                      Icons.notes_rounded,
                      'Catatan Kembali',
                      loan.returnNotes!,
                    ),
                  const SizedBox(height: 14),

                  // Tombol selesaikan pinjaman jika sedang digunakan
                  if (isInUse) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showCompleteLoanDialog(context, loan);
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Selesaikan Pinjaman'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkDialog ? Colors.white70 : const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
      ),
    );
  }

  Future<void> _showCompleteLoanDialog(
    BuildContext context,
    LoanRequest loan,
  ) async {
    final isDark = ThemeService.isDarkMode;
    final now = DateTime.now();
    final bool isEarly = now.isBefore(loan.endDate);

    final kmController = TextEditingController(
      text: loan.returnOdometer != null
          ? loan.returnOdometer.toString()
          : '45350',
    );
    String selectedFuel = loan.returnFuel?.toString() ?? 'Penuh (100%)';
    final notesController = TextEditingController(
      text: loan.returnNotes ??
          (isEarly
              ? 'Tugas kedinasan selesai lebih cepat dari jadwal semula. Kendaraan dikembalikan dalam kondisi baik dan bersih.'
              : 'Tugas kedinasan selesai sesuai jadwal. Kendaraan dikembalikan lengkap.'),
    );

    final fuelOptions = [
      'Penuh (100%)',
      '3/4 (75%)',
      '1/2 (50%)',
      '1/4 (25%)',
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Theme(
              data: isDark ? ThemeService.darkTheme : ThemeService.lightTheme,
              child: Dialog(
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.task_alt_rounded,
                                color: Color(0xFF059669),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selesaikan Pinjaman',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    loan.vehicleName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.close_rounded),
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // BANNER INFO PENYELESAIAN LEBIH CEPAT
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFBBF7D0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isEarly
                                        ? Icons.bolt_rounded
                                        : Icons.event_available_rounded,
                                    size: 16,
                                    color: isEarly
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF059669),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isEarly
                                        ? 'Pengembalian Lebih Cepat dari Jadwal'
                                        : 'Pengembalian Sesuai Jadwal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isEarly
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Jadwal semula: ${_formatDate(loan.startDate)} s/d ${_formatDate(loan.endDate)}\n'
                                'Diselesaikan: ${_formatDate(now)} (Hari Ini)',
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.4,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Odometer Akhir (KM)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: kmController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Contoh: 45350',
                            prefixIcon: const Icon(Icons.speed_rounded, size: 18),
                            suffixText: 'KM',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text(
                          'Sisa Bahan Bakar (BBM)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: fuelOptions.map((f) {
                            final isSel = selectedFuel == f;
                            return ChoiceChip(
                              label: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                ),
                              ),
                              selected: isSel,
                              selectedColor: const Color(0xFF059669),
                              backgroundColor: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF1F5F9),
                              onSelected: (_) {
                                setDialogState(() => selectedFuel = f);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        Text(
                          'Catatan Pengembalian',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: notesController,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Kondisi kendaraan saat diserahkan kembali...',
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final parsedKm = int.tryParse(kmController.text.replaceAll('.', '').replaceAll(',', '')) ?? 45350;
                                  Navigator.pop(dialogContext);

                                  setState(() {
                                    loan.status = LoanStatus.selesai;
                                    loan.returnOdometer = parsedKm;
                                    loan.returnFuel = selectedFuel;
                                    loan.returnNotes = notesController.text.trim();
                                  });

                                  widget.onLoanCompleted?.call(loan);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Peminjaman ${loan.vehicleName} berhasil diselesaikan${isEarly ? ' lebih cepat' : ''}! Status kini Selesai.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color(0xFF059669),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_rounded, size: 16),
                                label: const Text('Selesaikan Pinjaman'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF059669),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmStartUsingLoan(
    BuildContext context,
    LoanRequest loan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Mulai Gunakan Armada?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Kendaraan ${loan.vehicleName} akan dipindahkan ke tab "Digunakan" untuk penugasan dinas.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Mulai Gunakan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    setState(() => loan.status = LoanStatus.digunakan);
    widget.onLoanStarted?.call(loan);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Armada ${loan.vehicleName} sekarang berstatus Digunakan.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0284C7),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final isDark = ThemeService.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancellation(
    BuildContext context,
    LoanRequest loan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Batalkan Pinjaman?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Pengajuan ${loan.vehicleName} akan dipindahkan ke daftar Dibatalkan.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    setState(() => loan.status = LoanStatus.dibatalkan);
    widget.onLoanCancelled?.call(loan);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pinjaman berhasil dibatalkan.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

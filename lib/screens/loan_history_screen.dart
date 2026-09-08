import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';

class LoanHistoryScreen extends StatefulWidget {
  final List<LoanRequest> loans;
  final ValueChanged<LoanRequest>? onLoanTap;
  final ValueChanged<LoanRequest>? onLoanCancelled;

  const LoanHistoryScreen({
    super.key,
    required this.loans,
    this.onLoanTap,
    this.onLoanCancelled,
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
    return widget.loans.where((loan) {
      if (!_matchesSelectedMonth(loan)) return false;
      switch (tabIndex) {
        case 0:
          return _isWaiting(loan.status);
        case 1:
          return _isApproved(loan.status);
        case 2:
          return loan.status == LoanStatus.selesai;
        case 3:
          return loan.status == LoanStatus.ditolak ||
              loan.status == LoanStatus.rejected;
        default:
          return loan.status == LoanStatus.dibatalkan;
      }
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          title: const Text(
            'Riwayat Peminjaman',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF24487A),
            unselectedLabelColor: Color(0xFF64748B),
            indicatorColor: Color(0xFF24487A),
            tabs: [
              Tab(text: 'Menunggu'),
              Tab(text: 'Disetujui'),
              Tab(text: 'Selesai'),
              Tab(text: 'Ditolak'),
              Tab(text: 'Dibatalkan'),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Text(
                'Pantau status seluruh pengajuan kendaraan dinas Anda.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: DropdownButtonFormField<DateTime?>(
                initialValue: _selectedMonth,
                isDense: true,
                decoration: InputDecoration(
                  labelText: 'Filter bulan peminjaman',
                  labelStyle: const TextStyle(fontSize: 11),
                  prefixIcon: const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                items: [
                  const DropdownMenuItem<DateTime?>(
                    value: null,
                    child: Text('Semua bulan', style: TextStyle(fontSize: 12)),
                  ),
                  ..._availableMonths.map(
                    (month) => DropdownMenuItem<DateTime?>(
                      value: month,
                      child: Text(
                        _monthLabel(month),
                        style: const TextStyle(fontSize: 12),
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

    if (filteredLoans.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada pengajuan pada kategori ini.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: filteredLoans.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final loan = filteredLoans[index];
        return _buildLoanCard(context, loan);
      },
    );
  }

  Widget _buildLoanCard(BuildContext context, LoanRequest loan) {
    final isApproved = _isApproved(loan.status);
    final isCompleted = loan.status == LoanStatus.selesai;
    final isRejected =
        loan.status == LoanStatus.ditolak || loan.status == LoanStatus.rejected;
    final isCancelled = loan.status == LoanStatus.dibatalkan;
    final statusLabel = isCompleted
        ? 'SELESAI'
        : isApproved
        ? 'DISETUJUI'
        : isRejected
        ? 'DITOLAK'
        : isCancelled
        ? 'DIBATALKAN'
        : 'MENUNGGU';
    final statusBackground = isCompleted
        ? const Color(0xFFDBEAFE)
        : isApproved
        ? const Color(0xFFDCFCE7)
        : isRejected
        ? const Color(0xFFFEE2E2)
        : isCancelled
        ? const Color(0xFFE2E8F0)
        : const Color(0xFFFEF3C7);
    final statusForeground = isCompleted
        ? const Color(0xFF1D4ED8)
        : isApproved
        ? const Color(0xFF15803D)
        : isRejected
        ? const Color(0xFFB91C1C)
        : isCancelled
        ? const Color(0xFF475569)
        : const Color(0xFFB45309);

    return InkWell(
      onTap: widget.onLoanTap == null ? null : () => widget.onLoanTap!(loan),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 10,
              offset: Offset(0, 3),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
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
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text(
              'Jadwal: ${_formatDate(loan.startDate)} s/d ${_formatDate(loan.endDate)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0369A1),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (loan.spkNumber != null) ...[
              const SizedBox(height: 6),
              Text(
                'SPK: ${loan.spkNumber}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF24487A),
                ),
              ),
            ],
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

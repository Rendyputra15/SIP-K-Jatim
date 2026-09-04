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
  bool _isWaiting(LoanStatus status) =>
      status == LoanStatus.menunggu || status == LoanStatus.pending;

  bool _isApproved(LoanStatus status) =>
      status == LoanStatus.disetujui ||
      status == LoanStatus.approved ||
      status == LoanStatus.selesai;

  List<LoanRequest> _loansForTab(int tabIndex) {
    return widget.loans.where((loan) {
      switch (tabIndex) {
        case 0:
          return _isWaiting(loan.status);
        case 1:
          return _isApproved(loan.status);
        case 2:
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
      length: 4,
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
            labelColor: Color(0xFF24487A),
            unselectedLabelColor: Color(0xFF64748B),
            indicatorColor: Color(0xFF24487A),
            tabs: [
              Tab(text: 'Menunggu'),
              Tab(text: 'Disetujui'),
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
            Expanded(
              child: TabBarView(
                children: [
                  _buildLoanList(0),
                  _buildLoanList(1),
                  _buildLoanList(2),
                  _buildLoanList(3),
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
    final isRejected =
        loan.status == LoanStatus.ditolak || loan.status == LoanStatus.rejected;
    final isCancelled = loan.status == LoanStatus.dibatalkan;
    final statusLabel = isApproved
        ? 'DISETUJUI'
        : isRejected
        ? 'DITOLAK'
        : isCancelled
        ? 'DIBATALKAN'
        : 'MENUNGGU';
    final statusBackground = isApproved
        ? const Color(0xFFDCFCE7)
        : isRejected
        ? const Color(0xFFFEE2E2)
        : isCancelled
        ? const Color(0xFFE2E8F0)
        : const Color(0xFFFEF3C7);
    final statusForeground = isApproved
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

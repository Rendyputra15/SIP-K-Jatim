import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/screens/admin/dialogs/loan_detail_dialog.dart';
import 'package:simodis_jatim/screens/admin/dialogs/vehicle_return_dialog.dart';
import 'package:simodis_jatim/screens/admin/widgets/admin_loan_card.dart';

class AdminLoansTab extends StatefulWidget {
  final List<LoanRequest> requests;
  final Function(LoanRequest, bool) onVerify;
  final Function(LoanRequest, int, String, String) onReturn;

  const AdminLoansTab({
    super.key,
    required this.requests,
    required this.onVerify,
    required this.onReturn,
  });

  @override
  State<AdminLoansTab> createState() => _AdminLoansTabState();
}

class _AdminLoansTabState extends State<AdminLoansTab> {
  int _requestSubTabIndex = 0; // 0: Menunggu, 1: Aktif, 2: Riwayat

  Widget _buildFilterChip(int index, String label, bool hasBadge) {
    final isSelected = _requestSubTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _requestSubTabIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF24487A)
                    : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending =
        widget.requests
            .where(
              (r) =>
                  r.status == LoanStatus.menunggu ||
                  r.status == LoanStatus.pending,
            )
            .toList();
    final active =
        widget.requests
            .where(
              (r) =>
                  r.status == LoanStatus.disetujui ||
                  r.status == LoanStatus.approved,
            )
            .toList();
    final history =
        widget.requests
            .where(
              (r) =>
                  r.status == LoanStatus.selesai ||
                  r.status == LoanStatus.ditolak ||
                  r.status == LoanStatus.rejected,
            )
            .toList();

    List<LoanRequest> currentList;
    if (_requestSubTabIndex == 0) {
      currentList = pending;
    } else if (_requestSubTabIndex == 1) {
      currentList = active;
    } else {
      currentList = history;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              _buildFilterChip(
                0,
                'Menunggu (${pending.length})',
                pending.isNotEmpty,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(1, 'Sedang Dinas (${active.length})', false),
              const SizedBox(width: 8),
              _buildFilterChip(2, 'Riwayat BAST', false),
            ],
          ),
        ),
        Expanded(
          child:
              currentList.isEmpty
                  ? const Center(
                    child: Text(
                      'Tidak ada permohonan pada status ini',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: currentList.length,
                    itemBuilder: (ctx, i) {
                      final item = currentList[i];
                      return AdminLoanCard(
                        item: item,
                        onShowDetail:
                            () => LoanDetailDialog.show(
                              context,
                              loan: item,
                              onVerify: widget.onVerify,
                            ),
                        onShowReturn:
                            () => VehicleReturnDialog.show(
                              context,
                              loan: item,
                              onReturn: widget.onReturn,
                            ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

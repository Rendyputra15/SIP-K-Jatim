import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';

class AdminInfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AdminInfoLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        SizedBox(
          width: 85,
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
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class AdminLoanCard extends StatelessWidget {
  final LoanRequest item;
  final VoidCallback onShowDetail;
  final VoidCallback onShowReturn;

  const AdminLoanCard({
    super.key,
    required this.item,
    required this.onShowDetail,
    required this.onShowReturn,
  });

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    Color badgeBg;
    Color badgeText;
    String statusTitle;

    switch (item.status) {
      case LoanStatus.disetujui:
      case LoanStatus.approved:
        badgeBg = const Color(0xFFDCFCE7);
        badgeText = const Color(0xFF15803D);
        statusTitle = 'DISETUJUI (NOTA DINAS TERBIT)';
        break;
      case LoanStatus.ditolak:
      case LoanStatus.rejected:
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFFB91C1C);
        statusTitle = 'DITOLAK';
        break;
      case LoanStatus.selesai:
        badgeBg = const Color(0xFFEFF6FF);
        badgeText = const Color(0xFF1D4ED8);
        statusTitle = 'SELESAI (BAST TUNTAS)';
        break;
      default:
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFFB45309);
        statusTitle = 'MENUNGGU VERIFIKASI';
    }

    final isPending =
        item.status == LoanStatus.menunggu || item.status == LoanStatus.pending;
    final isActive =
        item.status == LoanStatus.disetujui ||
        item.status == LoanStatus.approved;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.vehicleName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusTitle,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pemohon: ${item.borrowerName} • ${item.department}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                AdminInfoLine(
                  icon: Icons.calendar_month_rounded,
                  label: 'Jadwal',
                  value:
                      '${_formatDate(item.startDate)} s/d ${_formatDate(item.endDate)}',
                ),
                const SizedBox(height: 4),
                AdminInfoLine(
                  icon: Icons.near_me_rounded,
                  label: 'Tujuan',
                  value: item.destination,
                ),
                const SizedBox(height: 4),
                AdminInfoLine(
                  icon: Icons.description_outlined,
                  label: 'Nota Dinas',
                  value:
                      item.officialNoteNumber.isEmpty
                          ? '-'
                          : item.officialNoteNumber,
                ),
                if (item.spkNumber != null) ...[
                  const SizedBox(height: 4),
                  AdminInfoLine(
                    icon: Icons.badge_outlined,
                    label: 'No. Register',
                    value: item.spkNumber!,
                  ),
                ],
              ],
            ),
          ),

          // FOOTER KARTU MENUNGGU VERIFIKASI: HANYA ADA TOMBOL "LIHAT DETAIL" DI KIRI BAWAH
          if (isPending) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onShowDetail,
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text(
                    'Lihat Detail Pengajuan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24487A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],

          // FOOTER KARTU AKTIF: PROSES BAST
          if (isActive) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onShowReturn,
                  icon: const Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Terima Unit & Proses BAST',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24487A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

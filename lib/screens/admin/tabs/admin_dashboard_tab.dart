import 'package:flutter/material.dart';
import 'package:simodis_jatim/screens/admin/widgets/admin_stat_card.dart';

class AdminDashboardTab extends StatelessWidget {
  final int pendingCount;
  final int activeCount;
  final int completedCount;
  final int totalVehicles;

  const AdminDashboardTab({
    super.key,
    required this.pendingCount,
    required this.activeCount,
    required this.completedCount,
    required this.totalVehicles,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Operasional',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          // Row 1: Status Pengajuan
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                AdminStatCard(
                  title: 'Antrean Masuk',
                  value: pendingCount.toString(),
                  sub: 'Butuh Verifikasi',
                  icon: Icons.hourglass_empty_rounded,
                  color: const Color(0xFFF59E0B),
                ),
                AdminStatCard(
                  title: 'Armada Jalan',
                  value: activeCount.toString(),
                  sub: 'Sedang Bertugas',
                  icon: Icons.local_shipping_rounded,
                  color: const Color(0xFF10B981),
                ),
              ];
              return constraints.maxWidth < 560
                  ? Column(
                    children: [
                      cards[0],
                      const SizedBox(height: 12),
                      cards[1],
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[1]),
                    ],
                  );
            },
          ),
          const SizedBox(height: 16),

          // Row 2: Riwayat & Total
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                AdminStatCard(
                  title: 'BAST Selesai',
                  value: completedCount.toString(),
                  sub: 'Total Riwayat',
                  icon: Icons.assignment_turned_in_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                AdminStatCard(
                  title: 'Total Armada',
                  value: totalVehicles.toString(),
                  sub: 'Unit Terdaftar',
                  icon: Icons.directions_car_rounded,
                  color: const Color(0xFF6366F1),
                ),
              ];
              return constraints.maxWidth < 560
                  ? Column(
                    children: [
                      cards[0],
                      const SizedBox(height: 12),
                      cards[1],
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[1]),
                    ],
                  );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Log Aktivitas Terakhir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // Mock Log Aktivitas agar dashboard menarik
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              children: [
                AdminLogItem(
                  title: 'Persetujuan Peminjaman',
                  desc: 'Admin menyetujui Toyota Innova (L 1023 SP)',
                  time: '10 Menit lalu',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                Divider(height: 24),
                AdminLogItem(
                  title: 'BAST Masuk',
                  desc: 'Pengembalian Unit Mitsubishi Pajero (L 4444 AS)',
                  time: '1 Jam lalu',
                  icon: Icons.assignment_returned_outlined,
                  color: Colors.blue,
                ),
                Divider(height: 24),
                AdminLogItem(
                  title: 'User Baru',
                  desc: 'Penambahan Akun Pegawai: Alamsyah',
                  time: '3 Jam lalu',
                  icon: Icons.person_add_outlined,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

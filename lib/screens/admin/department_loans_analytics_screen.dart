import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_performance_tab.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class DepartmentDataModel {
  final String fullName;
  final String shortName;
  final int borrowCount;
  final double percentage;
  final IconData icon;
  final Color color;
  final String topVehicle;

  const DepartmentDataModel({
    required this.fullName,
    required this.shortName,
    required this.borrowCount,
    required this.percentage,
    required this.icon,
    required this.color,
    required this.topVehicle,
  });
}

class DepartmentLoansAnalyticsScreen extends StatefulWidget {
  final List<LoanRequest> requests;
  final List<Vehicle> vehicles;
  final PerformancePeriod initialPeriod;

  const DepartmentLoansAnalyticsScreen({
    super.key,
    required this.requests,
    required this.vehicles,
    this.initialPeriod = PerformancePeriod.bulanan,
  });

  @override
  State<DepartmentLoansAnalyticsScreen> createState() =>
      _DepartmentLoansAnalyticsScreenState();
}

class _DepartmentLoansAnalyticsScreenState
    extends State<DepartmentLoansAnalyticsScreen> {
  late PerformancePeriod _selectedPeriod;
  int _selectedBarIndex = -1;
  String _selectedDeptFilter = 'Semua';
  String _searchFilter = '';

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
  }

  List<DepartmentDataModel> _getDepartmentData() {
    // Data frekuensi berdasarkan periode
    final Map<String, (int, String, IconData, Color, String)> baseStats = switch (
        _selectedPeriod) {
      PerformancePeriod.harian => {
          'Bidang Perlindungan & Jaminan Sosial (Linjamsos)': (
            8,
            'Linjamsos',
            Icons.volunteer_activism_rounded,
            const Color(0xFF2563EB),
            'Toyota Innova Reborn',
          ),
          'Subbag Penyusunan Program & Anggaran': (
            6,
            'PPA',
            Icons.calculate_rounded,
            const Color(0xFF0D9488),
            'Toyota Avanza 1.5 G',
          ),
          'Bidang Rehabilitasi Sosial (Rehsos)': (
            5,
            'Rehsos',
            Icons.healing_rounded,
            const Color(0xFFD97706),
            'Toyota HiAce Commuter',
          ),
          'Bidang Penanganan Fakir Miskin (PFM)': (
            4,
            'PFM',
            Icons.family_restroom_rounded,
            const Color(0xFF6366F1),
            'Toyota Avanza 1.5 G',
          ),
          'Subbag Keuangan & Aset': (
            3,
            'Keuangan',
            Icons.account_balance_wallet_rounded,
            const Color(0xFF8B5CF6),
            'Toyota Innova Reborn',
          ),
        },
      PerformancePeriod.mingguan => {
          'Bidang Perlindungan & Jaminan Sosial (Linjamsos)': (
            18,
            'Linjamsos',
            Icons.volunteer_activism_rounded,
            const Color(0xFF2563EB),
            'Toyota Innova Reborn',
          ),
          'Subbag Penyusunan Program & Anggaran': (
            14,
            'PPA',
            Icons.calculate_rounded,
            const Color(0xFF0D9488),
            'Toyota Avanza 1.5 G',
          ),
          'Bidang Rehabilitasi Sosial (Rehsos)': (
            12,
            'Rehsos',
            Icons.healing_rounded,
            const Color(0xFFD97706),
            'Toyota HiAce Commuter',
          ),
          'Bidang Penanganan Fakir Miskin (PFM)': (
            10,
            'PFM',
            Icons.family_restroom_rounded,
            const Color(0xFF6366F1),
            'Toyota Avanza 1.5 G',
          ),
          'Subbag Keuangan & Aset': (
            7,
            'Keuangan',
            Icons.account_balance_wallet_rounded,
            const Color(0xFF8B5CF6),
            'Toyota Innova Reborn',
          ),
        },
      PerformancePeriod.bulanan => {
          'Bidang Perlindungan & Jaminan Sosial (Linjamsos)': (
            35,
            'Linjamsos',
            Icons.volunteer_activism_rounded,
            const Color(0xFF2563EB),
            'Toyota Innova Reborn',
          ),
          'Subbag Penyusunan Program & Anggaran': (
            28,
            'PPA',
            Icons.calculate_rounded,
            const Color(0xFF0D9488),
            'Toyota Avanza 1.5 G',
          ),
          'Bidang Rehabilitasi Sosial (Rehsos)': (
            26,
            'Rehsos',
            Icons.healing_rounded,
            const Color(0xFFD97706),
            'Toyota HiAce Commuter',
          ),
          'Bidang Penanganan Fakir Miskin (PFM)': (
            20,
            'PFM',
            Icons.family_restroom_rounded,
            const Color(0xFF6366F1),
            'Toyota Avanza 1.5 G',
          ),
          'Subbag Keuangan & Aset': (
            16,
            'Keuangan',
            Icons.account_balance_wallet_rounded,
            const Color(0xFF8B5CF6),
            'Toyota Innova Reborn',
          ),
        },
    };

    final total =
        baseStats.values.fold<int>(0, (sum, item) => sum + item.$1);
    final safeTotal = total <= 0 ? 1 : total;

    return baseStats.entries.map((e) {
      final info = e.value;
      return DepartmentDataModel(
        fullName: e.key,
        shortName: info.$2,
        borrowCount: info.$1,
        percentage: info.$1 / safeTotal,
        icon: info.$3,
        color: info.$4,
        topVehicle: info.$5,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final isMobile = MediaQuery.sizeOf(context).width < 750;

    final deptData = _getDepartmentData();
    final totalBorrows = deptData.fold<int>(0, (sum, d) => sum + d.borrowCount);
    final topDept = deptData.isNotEmpty ? deptData.first : null;
    final maxCount = deptData.fold<int>(0, (max, d) => d.borrowCount > max ? d.borrowCount : max);
    final avgPerDept = (totalBorrows / (deptData.isEmpty ? 1 : deptData.length)).toStringAsFixed(1);

    // Filter berkas peminjaman
    final filteredLoans = widget.requests.where((r) {
      final matchesDept = _selectedDeptFilter == 'Semua' ||
          r.department.toLowerCase().contains(_selectedDeptFilter.toLowerCase());
      if (!matchesDept) return false;

      if (_searchFilter.isEmpty) return true;
      final q = _searchFilter.toLowerCase();
      return r.borrowerName.toLowerCase().contains(q) ||
          r.vehicleName.toLowerCase().contains(q) ||
          r.destination.toLowerCase().contains(q) ||
          r.department.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFF2563EB),
                  size: 19,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Grafik Peminjaman per Bidang',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              'Distribusi peminjaman mobil dinas antar bidang UPT Dinsos',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.apartment_rounded, size: 13, color: Color(0xFF1D4ED8)),
                const SizedBox(width: 4),
                Text(
                  isMobile ? '${deptData.length} Bidang' : '${deptData.length} Bidang Aktif',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner Ringkasan Distribusi Bidang
            _buildSummaryBanner(
              isDark: isDark,
              isMobile: isMobile,
              totalBorrows: totalBorrows,
              topDept: topDept,
              totalDepts: deptData.length,
            ),
            const SizedBox(height: 16),

            // 2. Filter Periode (Harian, Mingguan, Bulanan)
            _buildPeriodSelectorCard(isDark, isMobile),
            const SizedBox(height: 16),

            // 3. Grid Metrik Analitik 2x2
            _buildMetricsGrid(
              isDark: isDark,
              isMobile: isMobile,
              topDept: topDept,
              avgPerDept: avgPerDept,
              totalBorrows: totalBorrows,
              totalDepts: deptData.length,
            ),
            const SizedBox(height: 18),

            // 4. Grafik Utama: Gradient Column Chart Distribusi Bidang (Gambar 2)
            _buildDepartmentColumnChartCard(
              isDark: isDark,
              isMobile: isMobile,
              deptData: deptData,
              maxVal: maxCount,
            ),
            const SizedBox(height: 18),

            // 5. Ranking & Rincian Tiap Bidang
            _buildDepartmentLeaderboardCard(
              isDark: isDark,
              deptData: deptData,
            ),
            const SizedBox(height: 18),

            // 6. Rekapitulasi Berkas Peminjaman per Bidang
            _buildLoanHistorySection(
              isDark: isDark,
              carLoans: filteredLoans,
              deptData: deptData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBanner({
    required bool isDark,
    required bool isMobile,
    required int totalBorrows,
    required DepartmentDataModel? topDept,
    required int totalDepts,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.apartment_rounded,
              color: Colors.white,
              size: isMobile ? 26 : 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '$totalBorrows Tugas',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 23,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1D4ED8),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF16A34A)),
                          SizedBox(width: 4),
                          Text(
                            'Distribusi Seluruh Bidang',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  topDept != null
                      ? 'Bidang ${topDept.shortName} memimpin penggunaan terbanyak dengan ${topDept.borrowCount} tugas (${(topDept.percentage * 100).toStringAsFixed(0)}% dari total dinas).'
                      : 'Rekapitulasi penggunaan mobil dinas oleh $totalDepts bidang kerja.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFD97706)),
                          const SizedBox(width: 4),
                          Text(
                            'Top: ${topDept?.shortName ?? "-"}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.apartment_rounded, size: 12, color: Color(0xFF1D4ED8)),
                          const SizedBox(width: 4),
                          Text(
                            '$totalDepts Unit Kerja',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
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

  Widget _buildPeriodSelectorCard(bool isDark, bool isMobile) {
    final periodText = switch (_selectedPeriod) {
      PerformancePeriod.harian => 'Periode Harian (7 Hari Terakhir)',
      PerformancePeriod.mingguan => 'Periode Mingguan (5 Minggu)',
      PerformancePeriod.bulanan => 'Periode Bulanan (12 Bulan 2026)',
    };

    final buttons = Container(
      width: isMobile ? double.infinity : null,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          _buildPeriodBtn(PerformancePeriod.harian, 'Harian', isDark, isMobile),
          _buildPeriodBtn(PerformancePeriod.mingguan, 'Mingguan', isDark, isMobile),
          _buildPeriodBtn(PerformancePeriod.bulanan, 'Bulanan', isDark, isMobile),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 15,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        periodText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                buttons,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 15,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      periodText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                buttons,
              ],
            ),
    );
  }

  Widget _buildPeriodBtn(
    PerformancePeriod period,
    String label,
    bool isDark, [
    bool isMobile = false,
  ]) {
    final isSelected = _selectedPeriod == period;
    final btn = InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _selectedBarIndex = -1;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF24487A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF24487A).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );

    if (isMobile) {
      return Expanded(child: btn);
    }
    return btn;
  }

  Widget _buildMetricsGrid({
    required bool isDark,
    required bool isMobile,
    required DepartmentDataModel? topDept,
    required String avgPerDept,
    required int totalBorrows,
    required int totalDepts,
  }) {
    final topPct = topDept != null ? (topDept.percentage * 100).toStringAsFixed(0) : '0';

    final items = [
      _buildStatCard(
        title: 'Bidang Teraktif',
        val: topDept?.shortName ?? '-',
        sub: '${topDept?.borrowCount ?? 0} Tugas ($topPct%)',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFF2563EB),
        isDark: isDark,
      ),
      _buildStatCard(
        title: 'Rata-rata per Bidang',
        val: '$avgPerDept Tugas',
        sub: switch (_selectedPeriod) {
          PerformancePeriod.harian => 'Rata-rata per unit / hari',
          PerformancePeriod.mingguan => 'Rata-rata per unit / minggu',
          PerformancePeriod.bulanan => 'Rata-rata per unit / bulan',
        },
        icon: Icons.analytics_rounded,
        color: const Color(0xFF0D9488),
        isDark: isDark,
      ),
      _buildStatCard(
        title: 'Pangsa Terbesar',
        val: '$topPct% Armada',
        sub: 'Porsi bidang peringkat #1',
        icon: Icons.pie_chart_rounded,
        color: const Color(0xFFF59E0B),
        isDark: isDark,
      ),
      _buildStatCard(
        title: 'Unit Kerja Terdata',
        val: '$totalDepts Bidang',
        sub: 'UPT Dinsos Jatim',
        icon: Icons.apartment_rounded,
        color: const Color(0xFF8B5CF6),
        isDark: isDark,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: items[0]),
              const SizedBox(width: 10),
              Expanded(child: items[1]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: items[2]),
              const SizedBox(width: 10),
              Expanded(child: items[3]),
            ],
          ),
        ],
      );
    }

    return Row(
      children: items
          .map((c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: c,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String val,
    required String sub,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 8,
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentColumnChartCard({
    required bool isDark,
    required bool isMobile,
    required List<DepartmentDataModel> deptData,
    required int maxVal,
  }) {
    final safeMax = maxVal == 0 ? 1 : maxVal;
    final labels = deptData.map((d) => d.shortName).toList();
    final counts = deptData.map((d) => d.borrowCount).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Judul Gradient Column Chart Sesuai Gambar 2
          Text(
            'Gradient Column Chart - Distribusi Bidang',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Volume tugas dinas armada per unit kerja (${switch (_selectedPeriod) {
              PerformancePeriod.harian => 'Harian',
              PerformancePeriod.mingguan => 'Mingguan',
              PerformancePeriod.bulanan => 'Bulanan',
            }})',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),

          // Legend Top Center Sesuai Gambar 2
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.5),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFF38BDF8),
                        Color(0xFF34D399),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Sales_Volume (Frekuensi Peminjaman per Bidang)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // CustomPaint Chart
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  _handleTouch(details.localPosition, chartWidth, deptData.length);
                },
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('${_selectedPeriod.name}_dept_chart'),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, _) {
                    return CustomPaint(
                      size: Size(chartWidth, 205),
                      painter: _DepartmentColumnPainter(
                        data: counts,
                        maxVal: safeMax,
                        selectedIndex: _selectedBarIndex,
                        labels: labels,
                        isDark: isDark,
                        animationProgress: progress,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          if (_selectedBarIndex >= 0 && _selectedBarIndex < deptData.length)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                    : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF059669).withValues(alpha: 0.5)
                      : const Color(0xFFA7F3D0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF059669), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${deptData[_selectedBarIndex].fullName}: Terdata ${deptData[_selectedBarIndex].borrowCount} tugas (${(deptData[_selectedBarIndex].percentage * 100).toStringAsFixed(0)}%). Mobil favorit: ${deptData[_selectedBarIndex].topVehicle}.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _selectedBarIndex = -1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleTouch(Offset pos, double width, int count) {
    if (count <= 0 || width <= 0) return;
    const leftPad = 38.0;
    const rightPad = 14.0;
    final drawW = width - leftPad - rightPad;
    if (drawW <= 0) return;

    final slotW = drawW / count;
    final relX = pos.dx - leftPad;
    if (relX < 0 || relX > drawW) return;

    final idx = (relX / slotW).floor().clamp(0, count - 1);
    setState(() {
      if (_selectedBarIndex == idx) {
        _selectedBarIndex = -1;
      } else {
        _selectedBarIndex = idx;
      }
    });
  }

  Widget _buildDepartmentLeaderboardCard({
    required bool isDark,
    required List<DepartmentDataModel> deptData,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
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
              Row(
                children: [
                  const Icon(
                    Icons.leaderboard_rounded,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Peringkat Penggunaan Tiap Bidang',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Text(
                'Frekuensi',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          for (int i = 0; i < deptData.length; i++) ...[
            _buildDeptLeaderboardRow(deptData[i], i + 1, isDark),
            if (i != deptData.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildDeptLeaderboardRow(
    DepartmentDataModel item,
    int rank,
    bool isDark,
  ) {
    final (Color badgeBg, Color badgeTextColor, Color badgeBorder) = switch (rank) {
      1 => (const Color(0xFFFEF3C7), const Color(0xFFB45309), const Color(0xFFF59E0B)),
      2 => (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569), const Color(0xFF94A3B8)),
      3 => (const Color(0xFFFFEDD5), const Color(0xFFC2410C), const Color(0xFFFB923C)),
      _ => (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC), isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Badge nomor peringkat 1, 2, 3
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: badgeBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: badgeBorder.withValues(alpha: rank <= 3 ? 0.7 : 0.3),
                    width: rank <= 3 ? 1.5 : 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fullName,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Unit favorit: ${item.topVehicle}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.borrowCount} Tugas',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: rank == 1
                          ? const Color(0xFFD97706)
                          : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A)),
                    ),
                  ),
                  Text(
                    '${(item.percentage * 100).toStringAsFixed(0)}% dari total',
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: item.percentage,
              minHeight: 5,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                rank == 1
                    ? const Color(0xFF2563EB)
                    : (rank == 2
                        ? const Color(0xFF0D9488)
                        : (rank == 3 ? const Color(0xFFF59E0B) : const Color(0xFF8B5CF6))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanHistorySection({
    required bool isDark,
    required List<LoanRequest> carLoans,
    required List<DepartmentDataModel> deptData,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.history_edu_rounded,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Riwayat Tugas Kedinasan per Bidang',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${carLoans.length} Berkas',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          TextField(
            onChanged: (val) => setState(() => _searchFilter = val),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: 'Cari pemohon, bidang, kendaraan, tujuan...',
              hintStyle: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Chips Bidang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDeptChip('Semua', isDark),
                for (final d in deptData) ...[
                  const SizedBox(width: 6),
                  _buildDeptChip(d.shortName, isDark),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (carLoans.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Tidak ada berkas peminjaman untuk bidang ini.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: carLoans.take(8).length,
              separatorBuilder: (_, index) => Divider(
                height: 16,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                final item = carLoans[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24487A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Color(0xFF24487A),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  item.borrowerName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${item.startDate.day}/${item.startDate.month}/${item.startDate.year}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.department} • ${item.vehicleName}',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Tujuan: ${item.destination}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDeptChip(String label, bool isDark) {
    final isSelected = _selectedDeptFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedDeptFilter = label),
      labelStyle: TextStyle(
        fontSize: 10.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
      ),
      selectedColor: const Color(0xFF24487A),
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF24487A)
            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

/// CustomPainter untuk Grafik Batang Kolom Bergradasi per Bidang (Gambar 2)
class _DepartmentColumnPainter extends CustomPainter {
  final List<int> data;
  final int maxVal;
  final int selectedIndex;
  final List<String> labels;
  final bool isDark;
  final double animationProgress;

  _DepartmentColumnPainter({
    required this.data,
    required this.maxVal,
    required this.selectedIndex,
    required this.labels,
    required this.isDark,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final count = data.length;
    const leftPadding = 38.0;
    const rightPadding = 14.0;
    const topPadding = 20.0;
    const bottomPadding = 32.0;

    final drawableWidth = size.width - leftPadding - rightPadding;
    final drawableHeight = size.height - topPadding - bottomPadding;
    final baselineY = size.height - bottomPadding;

    if (drawableWidth <= 0 || drawableHeight <= 0) return;

    final axisLineColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final gridLineColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final textColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final safeMax = maxVal <= 0 ? 1 : maxVal;

    // 1. Grid horizontal & Label sumbu Y
    const steps = 4;
    for (int i = 0; i <= steps; i++) {
      final y = topPadding + (drawableHeight / steps) * i;
      final val = ((steps - i) * safeMax / steps).round();

      if (i < steps) {
        canvas.drawLine(
          Offset(leftPadding, y),
          Offset(size.width - rightPadding, y),
          Paint()
            ..color = gridLineColor
            ..strokeWidth = 1.0,
        );
      }

      final textSpan = TextSpan(
        text: '$val',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(leftPadding - 6 - tp.width, y - (tp.height / 2)));
    }

    // 2. Baseline Sumbu X
    canvas.drawLine(
      Offset(leftPadding, baselineY),
      Offset(size.width - rightPadding, baselineY),
      Paint()..color = axisLineColor..strokeWidth = 1.0,
    );

    // 3. Batang Kolom Bergradasi (Mint Green to Sky Blue - Gambar 2)
    final slotWidth = drawableWidth / count;
    final colWidth = (slotWidth * 0.58).clamp(12.0, 36.0);

    for (int i = 0; i < count; i++) {
      final val = data[i];
      final colCenterX = leftPadding + (i + 0.5) * slotWidth;
      final colLeft = colCenterX - (colWidth / 2);
      final isSelected = i == selectedIndex;

      final normalizedVal = (val / safeMax).clamp(0.0, 1.0);
      final colHeight = (normalizedVal * drawableHeight * animationProgress).clamp(2.0, drawableHeight);
      final colTop = baselineY - colHeight;

      final colRect = Rect.fromLTWH(colLeft, colTop, colWidth, colHeight);
      final rrect = RRect.fromRectAndCorners(
        colRect,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      final gradientPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(colCenterX, colTop),
          Offset(colCenterX, baselineY),
          [
            const Color(0xFF34D399),
            const Color(0xFF38BDF8),
          ],
        );
      canvas.drawRRect(rrect, gradientPaint);

      if (isSelected) {
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.95)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }

      // Label X-Axis (Nama Bidang)
      final label = labels[i];
      final labelSpan = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected
              ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
              : textColor,
        ),
      );
      final ltp = TextPainter(text: labelSpan, textDirection: TextDirection.ltr)..layout();
      ltp.paint(canvas, Offset(colCenterX - (ltp.width / 2), baselineY + 6));
    }

    // 4. Floating Tooltip Badge jika kolom dipilih
    if (selectedIndex >= 0 && selectedIndex < count) {
      final selVal = data[selectedIndex];
      final selCenterX = leftPadding + (selectedIndex + 0.5) * slotWidth;
      final normalizedVal = (selVal / safeMax).clamp(0.0, 1.0);
      final selColHeight = (normalizedVal * drawableHeight * animationProgress).clamp(2.0, drawableHeight);
      final selColTop = baselineY - selColHeight;

      final tooltipSpan = TextSpan(
        children: [
          TextSpan(
            text: '$selVal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const TextSpan(
            text: ' Tugas',
            style: TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
      final ttp = TextPainter(text: tooltipSpan, textDirection: TextDirection.ltr)..layout();

      const tooltipPadH = 9.0;
      const tooltipPadV = 4.0;
      final tooltipW = ttp.width + (tooltipPadH * 2);
      final tooltipH = ttp.height + (tooltipPadV * 2);
      final tooltipLeft = (selCenterX - (tooltipW / 2)).clamp(leftPadding, size.width - rightPadding - tooltipW);
      final tooltipTop = (selColTop - tooltipH - 8).clamp(2.0, baselineY);

      final tooltipRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipLeft, tooltipTop, tooltipW, tooltipH),
        const Radius.circular(6),
      );

      canvas.drawRRect(
        tooltipRect,
        Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        tooltipRect,
        Paint()
          ..color = const Color(0xFF34D399)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      ttp.paint(canvas, Offset(tooltipLeft + tooltipPadH, tooltipTop + tooltipPadV));
    }
  }

  @override
  bool shouldRepaint(covariant _DepartmentColumnPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data ||
        oldDelegate.isDark != isDark;
  }
}

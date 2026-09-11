import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/screens/admin/tabs/admin_performance_tab.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class TotalBorrowedCarsAnalyticsScreen extends StatefulWidget {
  final List<LoanRequest> requests;
  final List<Vehicle> vehicles;
  final PerformancePeriod initialPeriod;

  const TotalBorrowedCarsAnalyticsScreen({
    super.key,
    required this.requests,
    required this.vehicles,
    this.initialPeriod = PerformancePeriod.bulanan,
  });

  @override
  State<TotalBorrowedCarsAnalyticsScreen> createState() =>
      _TotalBorrowedCarsAnalyticsScreenState();
}

class _TotalBorrowedCarsAnalyticsScreenState
    extends State<TotalBorrowedCarsAnalyticsScreen> {
  late PerformancePeriod _selectedPeriod;
  int _selectedBarIndex = -1;
  String _searchFilter = '';

  final List<String> _dailyLabels = const [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  final List<String> _weeklyLabels = const [
    'Mgg 1',
    'Mgg 2',
    'Mgg 3',
    'Mgg 4',
    'Mgg 5',
  ];

  final List<String> _monthlyLabels = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
  }

  List<int> _generateTotalCarsTrend() {
    final carRequests = widget.requests.where((r) {
      return !r.vehicleName.toLowerCase().contains('vario') &&
          !r.vehicleName.toLowerCase().contains('nmax') &&
          !r.vehicleName.toLowerCase().contains('motor');
    }).toList();

    switch (_selectedPeriod) {
      case PerformancePeriod.harian:
        final counts = [18, 25, 38, 32, 45, 12, 8];
        for (final req in carRequests) {
          final idx = (req.startDate.weekday - 1).clamp(0, 6);
          counts[idx] += 1;
        }
        return counts;

      case PerformancePeriod.mingguan:
        final counts = [78, 95, 120, 84, 59];
        for (final req in carRequests) {
          final weekIdx = ((req.startDate.day - 1) ~/ 7).clamp(0, 4);
          counts[weekIdx] += 1;
        }
        return counts;

      case PerformancePeriod.bulanan:
        final counts = [32, 38, 45, 41, 52, 49, 39, 44, 50, 42, 35, 28];
        for (final req in carRequests) {
          final monthIdx = (req.startDate.month - 1).clamp(0, 11);
          counts[monthIdx] += 1;
        }
        return counts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final isMobile = MediaQuery.sizeOf(context).width < 750;

    final trendData = _generateTotalCarsTrend();
    final totalInPeriod = trendData.reduce((a, b) => a + b);
    final maxVal = trendData.reduce((a, b) => a > b ? a : b);
    final avgPerSlot = (totalInPeriod / trendData.length).toStringAsFixed(1);

    final totalCars = widget.vehicles.where((v) => v.type == VehicleType.mobil).length;
    final inUseCars = widget.vehicles
        .where((v) => v.type == VehicleType.mobil && v.status == VehicleStatus.digunakan)
        .length;
    final standbyCars = totalCars - inUseCars;

    // Riwayat berkas mobil yang sesuai pencarian
    final carLoans = widget.requests.where((r) {
      final isCar = !r.vehicleName.toLowerCase().contains('vario') &&
          !r.vehicleName.toLowerCase().contains('nmax');
      if (!isCar) return false;
      if (_searchFilter.isEmpty) return true;
      return r.borrowerName.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          r.vehicleName.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          r.destination.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          r.department.toLowerCase().contains(_searchFilter.toLowerCase());
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
                  Icons.directions_car_filled_rounded,
                  color: Color(0xFF2563EB),
                  size: 19,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Grafik Total Mobil Dipinjam',
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
              'Statistik akumulasi & tren volume peminjaman mobil',
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
                const Icon(Icons.analytics_rounded, size: 13, color: Color(0xFF1D4ED8)),
                const SizedBox(width: 4),
                Text(
                  isMobile ? '$totalInPeriod Total' : '$totalInPeriod Peminjaman',
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
            // 1. Banner Ringkasan Total Mobil Dipinjam
            _buildTotalSummaryBanner(
              isDark: isDark,
              isMobile: isMobile,
              totalBorrows: totalInPeriod,
              inUseCars: inUseCars,
              standbyCars: standbyCars,
              totalCars: totalCars,
            ),
            const SizedBox(height: 16),

            // 2. Baris Filter Periode (Harian, Mingguan, Bulanan)
            _buildPeriodSelectorCard(isDark, isMobile),
            const SizedBox(height: 16),

            // 3. Grid Kartu Metrik Analitik Peminjaman
            _buildMetricsGrid(
              isDark: isDark,
              isMobile: isMobile,
              totalBorrows: totalInPeriod,
              avgPerSlot: avgPerSlot,
              maxVal: maxVal,
              inUseCars: inUseCars,
            ),
            const SizedBox(height: 18),

            // 4. Grafik Utama: Gradient Column Chart (Gambar 2)
            _buildMainColumnChartCard(
              isDark: isDark,
              isMobile: isMobile,
              trendData: trendData,
              maxVal: maxVal,
            ),
            const SizedBox(height: 18),

            // 5. Sebaran Bidang Pemohon & Kategori Mobil
            if (isMobile) ...[
              _buildDepartmentBreakdownCard(isDark),
              const SizedBox(height: 16),
              _buildVehicleBreakdownCard(isDark),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildDepartmentBreakdownCard(isDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: _buildVehicleBreakdownCard(isDark),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),

            // 6. Rekapitulasi Berkas Peminjaman Mobil
            _buildLoanHistoryCard(isDark, carLoans),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummaryBanner({
    required bool isDark,
    required bool isMobile,
    required int totalBorrows,
    required int inUseCars,
    required int standbyCars,
    required int totalCars,
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
              Icons.directions_car_filled_rounded,
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
                      '$totalBorrows Kali',
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
                            'Total Mobil Dipinjam',
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
                  'Rekapitulasi $totalCars unit armada mobil dinas Dinsos Jatim:',
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
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$inUseCars Unit Bertugas',
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
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$standbyCars Unit Standby',
                            style: const TextStyle(
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
    required int totalBorrows,
    required String avgPerSlot,
    required int maxVal,
    required int inUseCars,
  }) {
    final items = [
      _buildStatCard(
        title: 'Akumulasi Pinjam',
        val: '$totalBorrows Unit',
        sub: 'Total mobil keluar dinas',
        icon: Icons.directions_car_filled_rounded,
        color: const Color(0xFF2563EB),
        isDark: isDark,
      ),
      _buildStatCard(
        title: 'Rata-rata Pinjam',
        val: '$avgPerSlot Unit',
        sub: switch (_selectedPeriod) {
          PerformancePeriod.harian => 'Rata-rata unit / hari',
          PerformancePeriod.mingguan => 'Rata-rata unit / minggu',
          PerformancePeriod.bulanan => 'Rata-rata unit / bulan',
        },
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF0D9488),
        isDark: isDark,
      ),
      _buildStatCard(
        title: 'Puncak Peminjaman',
        val: '$maxVal Unit',
        sub: 'Volume puncak tercatat',
        icon: Icons.vertical_align_top_rounded,
        color: const Color(0xFFF59E0B),
        isDark: isDark,
      ),
      _buildStatCard(
        title: 'Armada Aktif Lapangan',
        val: '$inUseCars Unit',
        sub: 'Berdinas saat ini',
        icon: Icons.car_rental_rounded,
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
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.3,
            ),
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

  Widget _buildMainColumnChartCard({
    required bool isDark,
    required bool isMobile,
    required List<int> trendData,
    required int maxVal,
  }) {
    final labels = switch (_selectedPeriod) {
      PerformancePeriod.harian => _dailyLabels,
      PerformancePeriod.mingguan => _weeklyLabels,
      PerformancePeriod.bulanan => _monthlyLabels,
    };

    final safeMax = maxVal == 0 ? 1 : maxVal;

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
            'Gradient Column Chart',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Volume Total Seluruh Mobil Dinas Dipinjam (${switch (_selectedPeriod) {
              PerformancePeriod.harian => 'Harian / 7 Hari',
              PerformancePeriod.mingguan => 'Mingguan / 5 Minggu',
              PerformancePeriod.bulanan => 'Bulanan / 12 Bulan',
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
                  'Sales_Volume (Total Mobil Dipinjam)',
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
                  _handleTouch(details.localPosition, chartWidth, trendData.length);
                },
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('${_selectedPeriod.name}_total_cars_gradient_chart'),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, _) {
                    return CustomPaint(
                      size: Size(chartWidth, 205),
                      painter: _TotalCarsColumnPainter(
                        data: trendData,
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

          if (_selectedBarIndex >= 0 && _selectedBarIndex < trendData.length)
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
                      'Periode ${labels[_selectedBarIndex]}: Terdata total ${trendData[_selectedBarIndex]} kali mobil dinas keluar bertugas.',
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

  Widget _buildDepartmentBreakdownCard(bool isDark) {
    final deptData = {
      'Subbag Penyusunan Program & Anggaran': 92,
      'Bidang Perlindungan & Jaminan Sosial (Linjamsos)': 135,
      'Bidang Rehabilitasi Sosial (Rehsos)': 88,
      'Bidang Penanganan Fakir Miskin (PFM)': 71,
      'Subbag Keuangan & Aset': 50,
    };
    final total = deptData.values.fold<int>(0, (a, b) => a + b);

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
              Text(
                'Akumulasi Peminjaman per Bidang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
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
          for (final entry in deptData.entries) ...[
            _buildBarItem(entry.key, entry.value, total, isDark),
            if (entry.key != deptData.keys.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildBarItem(String label, int val, int total, bool isDark) {
    final pct = total == 0 ? 0.0 : (val / total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$val Pinjaman (${(pct * 100).toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(
              pct > 0.25 ? const Color(0xFF2563EB) : const Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleBreakdownCard(bool isDark) {
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
          Text(
            'Sebaran Tipe Mobil Dinas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          _buildTypeRow('Mobil MPV (Innova & Avanza)', '68%', Icons.directions_car_rounded, const Color(0xFF2563EB), isDark),
          Divider(height: 18, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          _buildTypeRow('Minibus Elf & HiAce', '22%', Icons.airport_shuttle_rounded, const Color(0xFF059669), isDark),
          Divider(height: 18, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          _buildTypeRow('SUV Tanggap Bencana', '10%', Icons.terrain_rounded, const Color(0xFFD97706), isDark),
        ],
      ),
    );
  }

  Widget _buildTypeRow(String title, String pct, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ),
        Text(
          pct,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLoanHistoryCard(bool isDark, List<LoanRequest> loans) {
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
                  const Icon(Icons.history_edu_rounded, color: Color(0xFF2563EB), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Riwayat Berkas Peminjaman Mobil',
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
                  '${loans.length} Berkas',
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
              hintText: 'Cari pemohon, mobil, atau destinasi dinas...',
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
          const SizedBox(height: 14),

          if (loans.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Tidak ada berkas peminjaman mobil yang cocok.',
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
              itemCount: loans.take(8).length,
              separatorBuilder: (context, index) => Divider(
                height: 16,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                final item = loans[index];
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
                        Icons.directions_car_filled_rounded,
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
                            '${item.vehicleName} • ${item.department}',
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
}

/// Painter Gradient Column Chart untuk Total Seluruh Mobil Dipinjam (Gambar 2)
class _TotalCarsColumnPainter extends CustomPainter {
  final List<int> data;
  final int maxVal;
  final int selectedIndex;
  final List<String> labels;
  final bool isDark;
  final double animationProgress;

  _TotalCarsColumnPainter({
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
    const bottomPadding = 30.0;

    final drawableWidth = size.width - leftPadding - rightPadding;
    final drawableHeight = size.height - topPadding - bottomPadding;

    if (drawableWidth <= 0 || drawableHeight <= 0) return;

    final rawMax = maxVal <= 0 ? 5 : maxVal;
    int step;
    if (rawMax <= 5) {
      step = 1;
    } else if (rawMax <= 15) {
      step = 3;
    } else if (rawMax <= 30) {
      step = 5;
    } else if (rawMax <= 60) {
      step = 10;
    } else {
      step = (rawMax / 5).ceil();
      if (step % 5 != 0) step = ((step / 5).ceil()) * 5;
    }

    final numTicks = (rawMax / step).ceil();
    final safeMax = (numTicks * step).clamp(1, 999999);
    final baselineY = size.height - bottomPadding;

    final axisLineColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final gridLineColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    // 1. Skala Y-Axis & Garis Kisi Halus
    for (int i = 0; i <= numTicks; i++) {
      final val = i * step;
      final y = baselineY - ((val / safeMax) * drawableHeight);

      if (i > 0) {
        final gridPaint = Paint()
          ..color = gridLineColor
          ..strokeWidth = 0.8;
        canvas.drawLine(
          Offset(leftPadding, y),
          Offset(size.width - rightPadding, y),
          gridPaint,
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
    final colWidth = (slotWidth * (count > 8 ? 0.68 : 0.58)).clamp(10.0, 36.0);

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

      // Label X-Axis
      final label = labels[i];
      final labelSpan = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: count > 8 ? 9.5 : 10.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
              : textColor,
        ),
      );
      final ltp = TextPainter(text: labelSpan, textDirection: TextDirection.ltr)..layout();
      ltp.paint(canvas, Offset(colCenterX - (ltp.width / 2), baselineY + 6));
    }

    // 4. Floating Tooltip Badge
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
            text: ' Mobil',
            style: TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
      final tp = TextPainter(text: tooltipSpan, textDirection: TextDirection.ltr);
      tp.layout();

      const padH = 8.0;
      const padV = 4.0;
      final pillW = tp.width + (padH * 2);
      final pillH = tp.height + (padV * 2);
      final pillX = (selCenterX - (pillW / 2)).clamp(4.0, size.width - pillW - 4.0);
      final pillY = (selColTop - pillH - 8).clamp(2.0, size.height - pillH);

      final pillRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pillX, pillY, pillW, pillH),
        const Radius.circular(6),
      );

      canvas.drawRRect(
        pillRRect.shift(const Offset(0, 2)),
        Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(pillRRect, Paint()..color = const Color(0xFF0F172A));
      canvas.drawRRect(
        pillRRect,
        Paint()
          ..color = const Color(0xFF34D399)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      tp.paint(canvas, Offset(pillX + padH, pillY + padV));
    }
  }

  @override
  bool shouldRepaint(covariant _TotalCarsColumnPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data ||
        oldDelegate.isDark != isDark;
  }
}

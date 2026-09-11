import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/screens/admin/department_loans_analytics_screen.dart';
import 'package:simodis_jatim/screens/admin/top_vehicle_analytics_screen.dart';
import 'package:simodis_jatim/screens/admin/total_borrowed_cars_analytics_screen.dart';
import 'package:simodis_jatim/services/theme_service.dart';

enum PerformancePeriod { harian, mingguan, bulanan }

/// Model data statistik mobil untuk perankingan mobil paling sering dipinjam
class VehiclePerformanceData {
  final Vehicle vehicle;
  final int borrowCount;
  final int totalDays;
  final double percentage;
  final List<LoanRequest> history;

  const VehiclePerformanceData({
    required this.vehicle,
    required this.borrowCount,
    required this.totalDays,
    required this.percentage,
    required this.history,
  });
}

class AdminPerformanceTab extends StatefulWidget {
  final List<LoanRequest> requests;
  final List<Vehicle> vehicles;

  const AdminPerformanceTab({
    super.key,
    required this.requests,
    required this.vehicles,
  });

  @override
  State<AdminPerformanceTab> createState() => _AdminPerformanceTabState();
}

class _AdminPerformanceTabState extends State<AdminPerformanceTab> {
  PerformancePeriod _selectedPeriod = PerformancePeriod.bulanan;
  int _selectedChartPointIndex = -1;
  String _searchCarQuery = '';

  // Label untuk grafik
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

  // Data historis baseline peminjaman mobil untuk grafik
  List<int> _generateChartTrendData() {
    // Hanya hitung peminjaman untuk kendaraan tipe mobil
    final carRequests = widget.requests.where((r) {
      final veh = widget.vehicles.where((v) => v.id == r.vehicleId).firstOrNull;
      if (veh != null) return veh.type == VehicleType.mobil;
      // Fallback cek nama mobil jika id tidak cocok
      return !r.vehicleName.toLowerCase().contains('vario') &&
          !r.vehicleName.toLowerCase().contains('nmax') &&
          !r.vehicleName.toLowerCase().contains('motor');
    }).toList();

    switch (_selectedPeriod) {
      case PerformancePeriod.harian:
        // 7 hari (Senin - Minggu)
        final counts = [3, 5, 9, 7, 11, 2, 1];
        for (final req in carRequests) {
          final idx = (req.startDate.weekday - 1).clamp(0, 6);
          counts[idx] += 1;
        }
        return counts;

      case PerformancePeriod.mingguan:
        // 5 minggu dalam bulan aktif
        final counts = [14, 22, 28, 17, 12];
        for (final req in carRequests) {
          final weekIdx = ((req.startDate.day - 1) ~/ 7).clamp(0, 4);
          counts[weekIdx] += 1;
        }
        return counts;

      case PerformancePeriod.bulanan:
        // 12 bulan (Jan - Des)
        final counts = [36, 42, 55, 48, 62, 70, 52, 60, 72, 47, 41, 33];
        for (final req in carRequests) {
          final monthIdx = (req.startDate.month - 1).clamp(0, 11);
          counts[monthIdx] += 1;
        }
        return counts;
    }
  }

  /// Menghitung peringkat mobil berdasarkan frekuensi peminjaman
  List<VehiclePerformanceData> _calculateVehicleRankings() {
    // Ambil daftar kendaraan tipe mobil saja
    final cars = widget.vehicles
        .where((v) => v.type == VehicleType.mobil)
        .toList();

    // Mapping bobot baseline historis sesuai periode agar data selalu informatif
    final baselineMultiplier = switch (_selectedPeriod) {
      PerformancePeriod.harian => 1,
      PerformancePeriod.mingguan => 4,
      PerformancePeriod.bulanan => 16,
    };

    // Baseline peminjaman default untuk mobil operasional Dinsos
    final Map<String, int> baseWeights = {
      'Toyota Innova Reborn 2.4 G': 12 * baselineMultiplier,
      'Toyota Avanza 1.3 Veloz': 9 * baselineMultiplier,
      'Isuzu Elf Minibus Dinsos Jatim': 6 * baselineMultiplier,
      'Mitsubishi Pajero Sport Dakar': 5 * baselineMultiplier,
      'Toyota HiAce Commuter': 4 * baselineMultiplier,
      'Daihatsu Terios R Custom': 3 * baselineMultiplier,
    };

    final Map<String, int> borrowCounts = {};
    final Map<String, int> daysCounts = {};
    final Map<String, List<LoanRequest>> historyMap = {};

    // Inisialisasi awal
    for (final car in cars) {
      final base = baseWeights[car.name] ?? (2 * baselineMultiplier);
      borrowCounts[car.id] = base;
      daysCounts[car.id] = (base * 1.8).round();
      historyMap[car.id] = [];
    }

    // Hitung data aktual dari widget.requests
    for (final req in widget.requests) {
      final veh = cars.where((c) => c.id == req.vehicleId || c.name == req.vehicleName).firstOrNull;
      if (veh != null) {
        borrowCounts[veh.id] = (borrowCounts[veh.id] ?? 0) + 1;
        final days = req.endDate.difference(req.startDate).inDays.clamp(1, 30);
        daysCounts[veh.id] = (daysCounts[veh.id] ?? 0) + days;
        historyMap[veh.id] = (historyMap[veh.id] ?? [])..add(req);
      }
    }

    final totalBorrows = borrowCounts.values.fold<int>(0, (a, b) => a + b);
    final safeTotal = totalBorrows <= 0 ? 1 : totalBorrows;

    final List<VehiclePerformanceData> list = [];
    for (final car in cars) {
      final count = borrowCounts[car.id] ?? 0;
      final days = daysCounts[car.id] ?? 0;
      final pct = (count / safeTotal);
      list.add(VehiclePerformanceData(
        vehicle: car,
        borrowCount: count,
        totalDays: days,
        percentage: pct,
        history: historyMap[car.id] ?? [],
      ));
    }

    // Urutkan dari yang paling banyak dipinjam (descending)
    list.sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
    return list;
  }

  void _showCarDetailPerformance(VehiclePerformanceData data) {
    final isDark = ThemeService.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      child: Image.asset(
                        data.vehicle.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.directions_car_rounded,
                          size: 36,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.vehicle.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF24487A),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                data.vehicle.plateNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${data.vehicle.capacity} Penumpang',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 16),
              Text(
                'Ringkasan Performa Mobil',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatBox(
                      'Total Peminjaman',
                      '${data.borrowCount} Kali',
                      Icons.history_rounded,
                      const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniStatBox(
                      'Pangsa Penggunaan',
                      '${(data.percentage * 100).toStringAsFixed(1)}%',
                      Icons.pie_chart_rounded,
                      const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniStatBox(
                      'Durasi Dinas',
                      '${data.totalDays} Hari',
                      Icons.date_range_rounded,
                      const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      data.vehicle.status == VehicleStatus.tersedia
                          ? Icons.check_circle_rounded
                          : Icons.access_time_filled_rounded,
                      size: 18,
                      color: data.vehicle.status == VehicleStatus.tersedia
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        data.vehicle.status == VehicleStatus.tersedia
                            ? 'Unit saat ini standby di Pool Kendaraan & siap ditugaskan.'
                            : 'Unit saat ini sedang digunakan dalam perjalanan dinas.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Text(
                        'Tutup',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopVehicleAnalyticsScreen(
                              vehicle: data.vehicle,
                              allRequests: widget.requests,
                              borrowCount: data.borrowCount,
                              totalDays: data.totalDays,
                              percentage: data.percentage,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart_rounded, size: 18),
                      label: const Text(
                        'Halaman Grafik ➔',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24487A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStatBox(String title, String value, IconData icon, Color color) {
    final isDark = ThemeService.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final isMobile = MediaQuery.sizeOf(context).width < 750;

    final rankings = _calculateVehicleRankings();
    final totalBorrows = rankings.fold<int>(0, (sum, item) => sum + item.borrowCount);
    final topVehicle = rankings.isNotEmpty ? rankings.first : null;
    final inUseCarsCount = widget.vehicles
        .where((v) => v.type == VehicleType.mobil && v.status == VehicleStatus.digunakan)
        .length;
    final totalCarsCount = widget.vehicles
        .where((v) => v.type == VehicleType.mobil)
        .length;
    final utilizationRate = totalCarsCount > 0
        ? ((inUseCarsCount / totalCarsCount) * 100).toStringAsFixed(0)
        : '0';

    final trendData = _generateChartTrendData();
    final maxTrendVal = trendData.reduce((a, b) => a > b ? a : b);

    // Filter daftar mobil jika ada pencarian
    final filteredRankings = _searchCarQuery.isEmpty
        ? rankings
        : rankings
            .where((r) =>
                r.vehicle.name
                    .toLowerCase()
                    .contains(_searchCarQuery.toLowerCase()) ||
                r.vehicle.plateNumber
                    .toLowerCase()
                    .contains(_searchCarQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Tab & Periode Selector (Harian, Mingguan, Bulanan)
            _buildPeriodSelectorCard(isDark, isMobile),
            const SizedBox(height: 16),

            // 2. Metrik Utama: Berapa banyak mobil dipinjam & Mobil terfavorit
            _buildMainMetricsRow(
              isDark: isDark,
              isMobile: isMobile,
              totalBorrows: totalBorrows,
              topVehicle: topVehicle,
              inUseCarsCount: inUseCarsCount,
              totalCarsCount: totalCarsCount,
              utilizationRate: utilizationRate,
            ),
            const SizedBox(height: 18),

            // 3. Leaderboard: Mobil Apa Saja yang Paling Banyak Dipinjam
            _buildTopVehiclesLeaderboard(
              isDark: isDark,
              isMobile: isMobile,
              rankings: filteredRankings,
              totalBorrows: totalBorrows,
            ),
            const SizedBox(height: 18),

            // 4. Grafik Tren Volume Peminjaman Mobil (Excel-style / Gambar 2)
            _buildTrendChartCard(
              isDark: isDark,
              trendData: trendData,
              maxVal: maxTrendVal,
            ),
            const SizedBox(height: 18),

            // 5. Sebaran Unit Kerja Pemohon & Kategori Mobil
            if (isMobile) ...[
              _buildDepartmentBreakdownCard(isDark),
              const SizedBox(height: 16),
              _buildCarCategoryBreakdownCard(isDark),
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
                    child: _buildCarCategoryBreakdownCard(isDark),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),

            // 6. Daftar Riwayat Berkas Mobil Terkini
            _buildRecentCarLoansList(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelectorCard(bool isDark, bool isMobile) {
    final periodText = switch (_selectedPeriod) {
      PerformancePeriod.harian => 'Hari Ini: Jumat, 11 September 2026',
      PerformancePeriod.mingguan => 'Minggu Ini: 7 - 13 September 2026 (Minggu ke-2)',
      PerformancePeriod.bulanan => 'Bulan Ini: September 2026 (Tahun Anggaran 2026)',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24487A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: Color(0xFF24487A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Performa Peminjaman Mobil',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Analisis frekuensi peminjaman armada dinas',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Segmented Buttons (Harian, Mingguan, Bulanan)
              if (!isMobile) ...[
                const SizedBox(width: 12),
                _buildPeriodToggles(isDark),
              ],
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 12),
            _buildPeriodToggles(isDark),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.event_note_rounded,
                  size: 14,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    periodText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodToggles(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodButton(PerformancePeriod.harian, 'Harian', isDark),
          _buildPeriodButton(PerformancePeriod.mingguan, 'Mingguan', isDark),
          _buildPeriodButton(PerformancePeriod.bulanan, 'Bulanan', isDark),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
    PerformancePeriod period,
    String label,
    bool isDark,
  ) {
    final isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _selectedChartPointIndex = -1;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF24487A)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
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
  }

  Widget _buildMainMetricsRow({
    required bool isDark,
    required bool isMobile,
    required int totalBorrows,
    required VehiclePerformanceData? topVehicle,
    required int inUseCarsCount,
    required int totalCarsCount,
    required String utilizationRate,
  }) {
    final cards = [
      _buildMetricCard(
        title: 'Berapa Banyak Mobil Dipinjam',
        value: '$totalBorrows Kali',
        subtitle: switch (_selectedPeriod) {
          PerformancePeriod.harian => 'Peminjaman hari ini • Ketuk lihat grafik',
          PerformancePeriod.mingguan => 'Peminjaman minggu ini • Ketuk lihat grafik',
          PerformancePeriod.bulanan => 'Peminjaman bulan ini • Ketuk lihat grafik',
        },
        icon: Icons.directions_car_filled_rounded,
        color: const Color(0xFF2563EB),
        isDark: isDark,
        actionLabel: 'Lihat Grafik ➔',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TotalBorrowedCarsAnalyticsScreen(
                requests: widget.requests,
                vehicles: widget.vehicles,
                initialPeriod: _selectedPeriod,
              ),
            ),
          );
        },
      ),
      _buildMetricCard(
        title: 'Mobil Paling Banyak Dipinjam',
        value: topVehicle?.vehicle.name.split(' ').take(2).join(' ') ?? '-',
        subtitle: topVehicle != null
            ? '${topVehicle.borrowCount} Kali (${(topVehicle.percentage * 100).toStringAsFixed(0)}% total) • Ketuk lihat grafik'
            : 'Belum ada data',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFF59E0B),
        isDark: isDark,
        actionLabel: 'Lihat Grafik ➔',
        onTap: topVehicle != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopVehicleAnalyticsScreen(
                      vehicle: topVehicle.vehicle,
                      allRequests: widget.requests,
                      borrowCount: topVehicle.borrowCount,
                      totalDays: topVehicle.totalDays,
                      percentage: topVehicle.percentage,
                      rank: 1,
                    ),
                  ),
                );
              }
            : null,
      ),
      _buildMetricCard(
        title: 'Mobil Sedang Digunakan',
        value: '$inUseCarsCount Unit',
        subtitle: 'Dari $totalCarsCount unit mobil dinas',
        icon: Icons.car_rental_rounded,
        color: const Color(0xFF10B981),
        isDark: isDark,
      ),
      _buildMetricCard(
        title: 'Tingkat Utilitas Armada',
        value: '$utilizationRate%',
        subtitle: 'Persentase mobil beroperasi',
        icon: Icons.speed_rounded,
        color: const Color(0xFF8B5CF6),
        isDark: isDark,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: c,
                ))
            .toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 850) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 10),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 10),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }
        return Row(
          children: cards
              .map((c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: c,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
    String? actionLabel,
  }) {
    final cardWidget = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: onTap != null
              ? color.withValues(alpha: isDark ? 0.6 : 0.4)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: onTap != null ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: onTap != null ? 0.08 : 0.04),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onTap != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: color.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel ?? 'Grafik ➔',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: cardWidget,
        ),
      );
    }
    return cardWidget;
  }

  /// Komponen Peringkat Mobil Paling Banyak Dipinjam (Leaderboard)
  Widget _buildTopVehiclesLeaderboard({
    required bool isDark,
    required bool isMobile,
    required List<VehiclePerformanceData> rankings,
    required int totalBorrows,
  }) {
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
          // Header Leaderboard & Search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.leaderboard_rounded,
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Peringkat Mobil Paling Banyak Dipinjam',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Urutan mobil dinas berdasarkan frekuensi peminjaman (${switch (_selectedPeriod) {
                        PerformancePeriod.harian => 'Harian',
                        PerformancePeriod.mingguan => 'Mingguan',
                        PerformancePeriod.bulanan => 'Bulanan',
                      }})',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Search Field Ringan
          TextField(
            onChanged: (val) => setState(() => _searchCarQuery = val),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: 'Cari nama mobil atau plat nomor...',
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
          const SizedBox(height: 16),

          if (rankings.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Tidak ada mobil yang sesuai dengan pencarian.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rankings.length,
              separatorBuilder: (context, index) => Divider(
                height: 16,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                final item = rankings[index];
                return _buildRankingItemRow(
                  rank: index + 1,
                  data: item,
                  isDark: isDark,
                  isMobile: isMobile,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRankingItemRow({
    required int rank,
    required VehiclePerformanceData data,
    required bool isDark,
    required bool isMobile,
  }) {
    // Badge Peringkat Angka (1, 2, 3)
    final (Color badgeBg, Color badgeTextColor, Color badgeBorder) = switch (rank) {
      1 => (const Color(0xFFFEF3C7), const Color(0xFFB45309), const Color(0xFFF59E0B)),
      2 => (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569), const Color(0xFF94A3B8)),
      3 => (const Color(0xFFFFEDD5), const Color(0xFFC2410C), const Color(0xFFFB923C)),
      _ => (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC), isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
    };

    return InkWell(
      onTap: () => _showCarDetailPerformance(data),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badge Peringkat Angka 1, 2, 3
            Container(
              width: 32,
              height: 32,
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
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Foto Thumbnail Mobil
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48,
                height: 48,
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                child: Image.asset(
                  data.vehicle.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.directions_car_rounded,
                    size: 24,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Info Mobil (Nama, Plat, Kategori) - Anti Overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          data.vehicle.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (rank == 1) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Terfavorit',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF24487A),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          data.vehicle.plateNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${data.vehicle.capacity} Penumpang • ${data.vehicle.transmission}',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Progress bar pangsa peminjaman
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: data.percentage,
                            minHeight: 4,
                            backgroundColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              rank == 1
                                  ? const Color(0xFFF59E0B)
                                  : (rank == 2
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF0D9488)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(data.percentage * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Frekuensi & Aksi Detail
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${data.borrowCount} Kali',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: rank == 1
                        ? const Color(0xFFD97706)
                        : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A)),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${data.totalDays} Hari Dinas',
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Komponen Grafik Tren Volume Peminjaman Mobil - Model Gradient Column Chart (Gambar 2)
  Widget _buildTrendChartCard({
    required bool isDark,
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
          // Header Judul Sesuai Gambar 2 (Gradient Column Chart)
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
            'Tren Volume Peminjaman Mobil (${switch (_selectedPeriod) {
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

          // Legend di Atas Tengah (Gambar 2: Box Gradient + Sales_Volume / Volume Peminjaman)
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
                        Color(0xFF38BDF8), // Cyan / Biru terang di bawah
                        Color(0xFF34D399), // Hijau mint / Emerald di atas
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Sales_Volume (Peminjaman)',
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

          // Visualisasi Gradient Column Chart
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  _handleTrendChartTouch(details.localPosition, chartWidth, trendData.length);
                },
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('${_selectedPeriod.name}_performance_gradient_bar'),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, _) {
                    return CustomPaint(
                      size: Size(chartWidth, 205),
                      painter: _GradientColumnChartPainter(
                        data: trendData,
                        maxVal: safeMax,
                        selectedIndex: _selectedChartPointIndex,
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

          if (_selectedChartPointIndex >= 0 && _selectedChartPointIndex < trendData.length)
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
                  const Icon(Icons.bar_chart_rounded, color: Color(0xFF059669), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Periode ${labels[_selectedChartPointIndex]}: Terdata total ${trendData[_selectedChartPointIndex]} kali mobil dinas dipinjam.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white : const Color(0xFF065F46),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _selectedChartPointIndex = -1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleTrendChartTouch(Offset localPosition, double chartWidth, int count) {
    if (count <= 0 || chartWidth <= 0) return;
    const leftPadding = 38.0;
    const rightPadding = 12.0;
    final drawableWidth = chartWidth - leftPadding - rightPadding;
    if (drawableWidth <= 0) return;

    final slotWidth = drawableWidth / count;
    final relativeX = localPosition.dx - leftPadding;
    if (relativeX < 0 || relativeX > drawableWidth) return;

    final index = (relativeX / slotWidth).floor().clamp(0, count - 1);

    setState(() {
      if (_selectedChartPointIndex == index) {
        _selectedChartPointIndex = -1;
      } else {
        _selectedChartPointIndex = index;
      }
    });
  }

  Widget _buildDepartmentBreakdownCard(bool isDark) {
    final Map<String, int> deptData = switch (_selectedPeriod) {
      PerformancePeriod.harian => {
          'Subbag Penyusunan Program & Anggaran': 6,
          'Bidang Perlindungan & Jaminan Sosial (Linjamsos)': 8,
          'Bidang Rehabilitasi Sosial (Rehsos)': 5,
          'Bidang Penanganan Fakir Miskin (PFM)': 4,
          'Subbag Keuangan & Aset': 3,
        },
      PerformancePeriod.mingguan => {
          'Subbag Penyusunan Program & Anggaran': 14,
          'Bidang Perlindungan & Jaminan Sosial (Linjamsos)': 18,
          'Bidang Rehabilitasi Sosial (Rehsos)': 12,
          'Bidang Penanganan Fakir Miskin (PFM)': 9,
          'Subbag Keuangan & Aset': 7,
        },
      PerformancePeriod.bulanan => {
          'Subbag Penyusunan Program & Anggaran': 28,
          'Bidang Perlindungan & Jaminan Sosial (Linjamsos)': 35,
          'Bidang Rehabilitasi Sosial (Rehsos)': 26,
          'Bidang Penanganan Fakir Miskin (PFM)': 20,
          'Subbag Keuangan & Aset': 16,
        },
    };
    final total = deptData.values.fold<int>(0, (a, b) => a + b);

    void openDepartmentAnalytics() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DepartmentLoansAnalyticsScreen(
            requests: widget.requests,
            vehicles: widget.vehicles,
            initialPeriod: _selectedPeriod,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF24487A).withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: openDepartmentAnalytics,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF24487A).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.apartment_rounded,
                              color: Color(0xFF24487A),
                              size: 15,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              'Peminjaman per Bidang',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: openDepartmentAnalytics,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.25 : 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.4 : 0.25),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat Grafik ➔',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final entry in deptData.entries) ...[
                  _buildBarRow(entry.key, entry.value, total, isDark),
                  if (entry.key != deptData.keys.last) const SizedBox(height: 10),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 13,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Ketuk kartu untuk melihat grafik lengkap & data per bidang',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarRow(String label, int val, int total, bool isDark) {
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
            const SizedBox(width: 8),
            Text(
              '$val Pinjaman (${(pct * 100).toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 10.5,
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

  Widget _buildCarCategoryBreakdownCard(bool isDark) {
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
            'Kategori Mobil Terpopuler',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          _buildCategoryItem('MPV Keluarga (Innova & Avanza)', '68%', Icons.directions_car_rounded, const Color(0xFF2563EB), isDark),
          Divider(height: 18, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          _buildCategoryItem('Minibus Rombongan (Elf & HiAce)', '22%', Icons.airport_shuttle_rounded, const Color(0xFF059669), isDark),
          Divider(height: 18, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          _buildCategoryItem('SUV Lapangan / Operasional', '10%', Icons.terrain_rounded, const Color(0xFFD97706), isDark),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, String pct, IconData icon, Color color, bool isDark) {
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

  Widget _buildRecentCarLoansList(bool isDark) {
    // Ambil riwayat peminjaman mobil terkini
    final carLoans = widget.requests.where((r) {
      return !r.vehicleName.toLowerCase().contains('vario') &&
          !r.vehicleName.toLowerCase().contains('nmax');
    }).toList();

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
          const SizedBox(height: 14),

          if (carLoans.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada riwayat berkas peminjaman mobil.',
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
              itemCount: carLoans.take(5).length,
              separatorBuilder: (context, index) => Divider(
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
                                  item.vehicleName,
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
                            'Peminjam: ${item.borrowerName} (${item.department})',
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

/// Custom Painter Gradient Column Chart untuk Tab Performa (Sesuai Gambar 2)
class _GradientColumnChartPainter extends CustomPainter {
  final List<int> data;
  final int maxVal;
  final int selectedIndex;
  final List<String> labels;
  final bool isDark;
  final double animationProgress;

  _GradientColumnChartPainter({
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
      if (step % 5 != 0) {
        step = ((step / 5).ceil()) * 5;
      }
    }

    final numTicks = (rawMax / step).ceil();
    final safeMax = (numTicks * step).clamp(1, 999999);
    final baselineY = size.height - bottomPadding;

    final axisLineColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final gridLineColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    // 1. Gambar Label Skala Sumbu Y di Sebelah Kiri & Garis Pandu Halus (Gambar 2)
    for (int i = 0; i <= numTicks; i++) {
      final val = i * step;
      final y = baselineY - ((val / safeMax) * drawableHeight);

      // Garis grid horizontal sangat halus (seperti pada Gambar 2)
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

      // Teks angka sumbu Y
      final valText = '$val';
      final textSpan = TextSpan(
        text: valText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - 6 - textPainter.width, y - (textPainter.height / 2)),
      );
    }

    // 2. Garis Basis Sumbu X di Bagian Bawah (Baseline)
    final baselinePaint = Paint()
      ..color = axisLineColor
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(leftPadding, baselineY),
      Offset(size.width - rightPadding, baselineY),
      baselinePaint,
    );

    // 3. Gambar Batang Kolom Bergradasi (Gradient Columns - Gambar 2)
    final slotWidth = drawableWidth / count;
    // Lebar kolom yang proporsional sesuai jumlah data
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

      // Gradasi warna vertikal: Hijau mint (#34D399) di bagian atas -> Biru cyan (#38BDF8) di bagian bawah (Persis Gambar 2)
      final gradientPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(colCenterX, colTop),
          Offset(colCenterX, baselineY),
          [
            const Color(0xFF34D399), // Mint green / Emerald (atas)
            const Color(0xFF38BDF8), // Cyan / Sky blue (bawah)
          ],
        );

      canvas.drawRRect(rrect, gradientPaint);

      // Efek visual saat kolom disentuh / dipilih
      if (isSelected) {
        final highlightBorder = Paint()
          ..color = Colors.white.withValues(alpha: isDark ? 0.95 : 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawRRect(rrect, highlightBorder);
      }

      // Label Sumbu X tepat di bawah masing-masing kolom batang (Gambar 2)
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
      final ltp = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      );
      ltp.layout();
      ltp.paint(
        canvas,
        Offset(colCenterX - (ltp.width / 2), baselineY + 6),
      );
    }

    // 4. Floating Tooltip Badge di Atas Kolom yang Dipilih
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

      // Shadow bayangan halus
      canvas.drawRRect(
        pillRRect.shift(const Offset(0, 2)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Background tooltip
      canvas.drawRRect(
        pillRRect,
        Paint()..color = const Color(0xFF0F172A),
      );
      // Border hijau mint
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
  bool shouldRepaint(covariant _GradientColumnChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data ||
        oldDelegate.isDark != isDark;
  }
}

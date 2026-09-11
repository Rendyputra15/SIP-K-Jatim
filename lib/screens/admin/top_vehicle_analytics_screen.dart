import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/services/theme_service.dart';

enum VehicleChartPeriod { harian, mingguan, bulanan }

class TopVehicleAnalyticsScreen extends StatefulWidget {
  final Vehicle vehicle;
  final List<LoanRequest> allRequests;
  final int borrowCount;
  final int totalDays;
  final double percentage;
  final int rank;

  const TopVehicleAnalyticsScreen({
    super.key,
    required this.vehicle,
    required this.allRequests,
    required this.borrowCount,
    required this.totalDays,
    required this.percentage,
    this.rank = 1,
  });

  @override
  State<TopVehicleAnalyticsScreen> createState() =>
      _TopVehicleAnalyticsScreenState();
}

class _TopVehicleAnalyticsScreenState extends State<TopVehicleAnalyticsScreen> {
  VehicleChartPeriod _selectedPeriod = VehicleChartPeriod.harian;
  int _selectedBarIndex = -1;

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

  List<int> _generateCarSpecificTrend() {
    // Cari request yang khusus untuk mobil ini
    final relevantRequests = widget.allRequests.where((r) {
      return r.vehicleId == widget.vehicle.id ||
          r.vehicleName.toLowerCase() == widget.vehicle.name.toLowerCase() ||
          r.vehicleName.toLowerCase().contains(widget.vehicle.name.toLowerCase().split(' ')[0]);
    }).toList();

    switch (_selectedPeriod) {
      case VehicleChartPeriod.harian:
        final counts = [2, 3, 4, 3, 5, 1, 0];
        for (final req in relevantRequests) {
          final idx = (req.startDate.weekday - 1).clamp(0, 6);
          counts[idx] += 1;
        }
        return counts;

      case VehicleChartPeriod.mingguan:
        final counts = [6, 9, 12, 8, 5];
        for (final req in relevantRequests) {
          final weekIdx = ((req.startDate.day - 1) ~/ 7).clamp(0, 4);
          counts[weekIdx] += 1;
        }
        return counts;

      case VehicleChartPeriod.bulanan:
        final counts = [12, 15, 21, 18, 24, 27, 20, 22, 28, 17, 15, 12];
        for (final req in relevantRequests) {
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

    final trendData = _generateCarSpecificTrend();
    final maxVal = trendData.reduce((a, b) => a > b ? a : b);

    // Ambil daftar riwayat dinas khusus mobil ini
    final vehicleLoans = widget.allRequests.where((r) {
      return r.vehicleId == widget.vehicle.id ||
          r.vehicleName.toLowerCase().contains('innova') ||
          r.vehicleName.toLowerCase().contains(widget.vehicle.name.toLowerCase().split(' ')[0]);
    }).toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
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
                  Icons.insights_rounded,
                  color: Color(0xFFF59E0B),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Grafik Analisis ${widget.vehicle.name}',
                    style: TextStyle(
                      fontSize: isMobile ? 13.5 : 15.5,
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
              'Statistik performa & tren peminjaman armada',
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
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB45309),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.rank}',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.rank == 1
                      ? (isMobile ? 'Top Mobil' : 'Paling Banyak Dipinjam')
                      : 'Peringkat #${widget.rank}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB45309),
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
            // 1. Profil & Status Mobil
            _buildCarHeaderBanner(isDark, isMobile),
            const SizedBox(height: 16),

            // 2. Baris Filter Periode (Harian, Mingguan, Bulanan)
            _buildPeriodFilterCard(isDark, isMobile),
            const SizedBox(height: 16),

            // 3. Metrik Ringkasan Peminjaman Mobil Ini
            _buildCarMetricsRow(isDark, isMobile),
            const SizedBox(height: 18),

            // 4. Grafik Utama Gradient Column Chart (Gambar 2)
            _buildGradientColumnChartCard(
              isDark: isDark,
              isMobile: isMobile,
              trendData: trendData,
              maxVal: maxVal,
            ),
            const SizedBox(height: 18),

            // 5. Sebaran Unit Pemohon & Destinasi Favorit
            if (isMobile) ...[
              _buildDepartmentUsageCard(isDark),
              const SizedBox(height: 16),
              _buildTopDestinationsCard(isDark),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildDepartmentUsageCard(isDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: _buildTopDestinationsCard(isDark),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),

            // 6. Riwayat Berkas Perjalanan Dinas Mobil Ini
            _buildVehicleLoanHistoryList(isDark, vehicleLoans),
          ],
        ),
      ),
    );
  }

  Widget _buildCarHeaderBanner(bool isDark, bool isMobile) {
    final isAvailable = widget.vehicle.status == VehicleStatus.tersedia;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFF8FAFC), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto / Logo Mobil
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: isMobile ? 72 : 90,
              height: isMobile ? 72 : 90,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(
                widget.vehicle.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.directions_car_rounded,
                  size: 40,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Detail Mobil
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24487A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.vehicle.plateNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isAvailable
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAvailable
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isAvailable ? 'Standby di Pool' : 'Sedang Digunakan',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isAvailable
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.vehicle.name,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildSpecPill('${widget.vehicle.capacity} Kursi', isDark),
                    _buildSpecPill(widget.vehicle.transmission, isDark),
                    _buildSpecPill(widget.vehicle.fuelType, isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecPill(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildPeriodFilterCard(bool isDark, bool isMobile) {
    final periodText = switch (_selectedPeriod) {
      VehicleChartPeriod.harian => 'Grafik Harian (7 Hari Terakhir)',
      VehicleChartPeriod.mingguan => 'Grafik Mingguan (5 Minggu)',
      VehicleChartPeriod.bulanan => 'Grafik Bulanan (12 Bulan 2026)',
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
          _buildPeriodBtn(VehicleChartPeriod.harian, 'Harian', isDark, isMobile),
          _buildPeriodBtn(VehicleChartPeriod.mingguan, 'Mingguan', isDark, isMobile),
          _buildPeriodBtn(VehicleChartPeriod.bulanan, 'Bulanan', isDark, isMobile),
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
                        Icons.calendar_today_rounded,
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
                        Icons.calendar_today_rounded,
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
    VehicleChartPeriod period,
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

  Widget _buildCarMetricsRow(bool isDark, bool isMobile) {
    final cards = [
      _buildStatItem(
        'Total Pinjam',
        '${widget.borrowCount} Kali',
        'Frekuensi kedinasan',
        Icons.assignment_turned_in_rounded,
        const Color(0xFF2563EB),
        isDark,
      ),
      _buildStatItem(
        'Total Hari Dinas',
        '${widget.totalDays} Hari',
        'Durasi operasional jalan',
        Icons.date_range_rounded,
        const Color(0xFF0D9488),
        isDark,
      ),
      _buildStatItem(
        'Pangsa Utilitas',
        '${(widget.percentage * 100).toStringAsFixed(0)}%',
        'Porsi dari armada Dinsos',
        Icons.pie_chart_rounded,
        const Color(0xFFF59E0B),
        isDark,
      ),
      _buildStatItem(
        'Rata-rata Durasi',
        '${(widget.totalDays / (widget.borrowCount <= 0 ? 1 : widget.borrowCount)).toStringAsFixed(1)} Hari',
        'Per berkas perjalanan',
        Icons.timelapse_rounded,
        const Color(0xFF8B5CF6),
        isDark,
      ),
    ];

    if (isMobile) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: c,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
    bool isDark,
  ) {
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
            value,
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

  Widget _buildGradientColumnChartCard({
    required bool isDark,
    required bool isMobile,
    required List<int> trendData,
    required int maxVal,
  }) {
    final labels = switch (_selectedPeriod) {
      VehicleChartPeriod.harian => _dailyLabels,
      VehicleChartPeriod.mingguan => _weeklyLabels,
      VehicleChartPeriod.bulanan => _monthlyLabels,
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
          // Header Judul Gradient Column Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gradient Column Chart - ${widget.vehicle.name}',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Grafik frekuensi peminjaman mobil ini (ketuk kolom untuk rincian)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.5),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFF38BDF8), Color(0xFF34D399)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Peminjaman',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // CustomPaint Gradient Column Chart
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  _handleTouch(details.localPosition, chartWidth, trendData.length);
                },
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('${_selectedPeriod.name}_top_car_chart'),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, _) {
                    return CustomPaint(
                      size: Size(chartWidth, 205),
                      painter: _SingleCarColumnChartPainter(
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
                      'Periode ${labels[_selectedBarIndex]}: ${widget.vehicle.name} dipinjam sebanyak ${trendData[_selectedBarIndex]} kali perjalanan dinas.',
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

  Widget _buildDepartmentUsageCard(bool isDark) {
    final deptBreakdown = {
      'Subbag Penyusunan Program & Anggaran': 6,
      'Bidang Perlindungan & Jaminan Sosial (Linjamsos)': 4,
      'Bidang Penanganan Fakir Miskin (PFM)': 2,
      'Bidang Rehabilitasi Sosial (Rehsos)': 1,
      'Subbag Keuangan & Aset': 1,
    };
    final total = deptBreakdown.values.fold<int>(0, (a, b) => a + b);

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
            'Sebaran Peminjam Berdasarkan Bidang',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in deptBreakdown.entries) ...[
            _buildDeptBar(entry.key, entry.value, total, isDark),
            if (entry.key != deptBreakdown.keys.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildDeptBar(String title, int val, int total, bool isDark) {
    final pct = total == 0 ? 0.0 : (val / total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$val Kali (${(pct * 100).toStringAsFixed(0)}%)',
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
              pct > 0.3 ? const Color(0xFF2563EB) : const Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopDestinationsCard(bool isDark) {
    final destinations = [
      ('Bakorwil III Malang & UPT Lawang', '5 Kali Perjalanan', Icons.location_on_rounded),
      ('Penyaluran Bantuan Bojonegoro', '4 Kali Perjalanan', Icons.local_shipping_rounded),
      ('Monev Magetan & Ponorogo', '3 Kali Perjalanan', Icons.verified_rounded),
      ('BPKAD & Kantor Gubernur Jatim', '2 Kali Perjalanan', Icons.account_balance_rounded),
    ];

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
            'Destinasi Perjalanan Terbanyak',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          for (final d in destinations) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24487A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(d.$3, size: 15, color: const Color(0xFF24487A)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.$1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        d.$2,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (d != destinations.last)
              Divider(
                height: 16,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleLoanHistoryList(bool isDark, List<LoanRequest> history) {
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
                  const Icon(Icons.history_edu_rounded,
                      color: Color(0xFF2563EB), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Riwayat Berkas Peminjaman Unit Ini',
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
                  '${history.length} Berkas Tercatat',
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

          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada riwayat berkas peminjaman untuk mobil ini.',
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
              itemCount: history.take(6).length,
              separatorBuilder: (context, index) => Divider(
                height: 16,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                final item = history[index];
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
                            item.department,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
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

/// Painter Gradient Column Chart untuk satu mobil spesifik (Model Gambar 2)
class _SingleCarColumnChartPainter extends CustomPainter {
  final List<int> data;
  final int maxVal;
  final int selectedIndex;
  final List<String> labels;
  final bool isDark;
  final double animationProgress;

  _SingleCarColumnChartPainter({
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

    // 1. Skala Sumbu Y
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

    // 3. Batang Kolom Bergradasi (Mint green to Sky blue - Gambar 2)
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

      // Label Sumbu X
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
            text: ' Trip',
            style: TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
      final tp = TextPainter(text: tooltipSpan, textDirection: TextDirection.ltr)..layout();

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
  bool shouldRepaint(covariant _SingleCarColumnChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data ||
        oldDelegate.isDark != isDark;
  }
}

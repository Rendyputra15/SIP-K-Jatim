import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/screens/admin/dialogs/loan_detail_dialog.dart';
import 'package:simodis_jatim/services/theme_service.dart';

enum QueueChartPeriod { harian, mingguan, bulanan }

class AdminQueueAnalyticsScreen extends StatefulWidget {
  final List<LoanRequest> requests;
  final List<Vehicle> vehicles;
  final Function(LoanRequest, bool)? onVerify;

  const AdminQueueAnalyticsScreen({
    super.key,
    required this.requests,
    required this.vehicles,
    this.onVerify,
  });

  @override
  State<AdminQueueAnalyticsScreen> createState() =>
      _AdminQueueAnalyticsScreenState();
}

class _AdminQueueAnalyticsScreenState extends State<AdminQueueAnalyticsScreen> {
  QueueChartPeriod _selectedPeriod = QueueChartPeriod.harian;
  bool _onlyPending = false;
  int _selectedPointIndex = -1;

  // Data label untuk masing-masing filter
  final List<String> _dailyLabels = const [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  final List<String> _dailyFullLabels = const [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  final List<String> _weeklyLabels = const [
    'Mgg 1',
    'Mgg 2',
    'Mgg 3',
    'Mgg 4',
    'Mgg 5',
  ];

  final List<String> _weeklyFullLabels = const [
    'Minggu ke-1 (Tgl 1 - 7)',
    'Minggu ke-2 (Tgl 8 - 14)',
    'Minggu ke-3 (Tgl 15 - 21)',
    'Minggu ke-4 (Tgl 22 - 28)',
    'Minggu ke-5 (Tgl 29 - 31)',
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

  final List<String> _monthlyFullLabels = const [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September (Bulan Aktif)',
    'Oktober',
    'November',
    'Desember',
  ];

  // Menghasilkan data grafik gabungan (data riil + data historis rekapitulasi)
  List<int> _generateChartData() {
    final pendingOnly = _onlyPending;
    final rawRequests = widget.requests;

    switch (_selectedPeriod) {
      case QueueChartPeriod.harian:
        // Baseline mingguan + hitung submittedAt dari data riil
        final counts = [4, 7, 12, 9, 14, 3, 1];
        for (final req in rawRequests) {
          if (pendingOnly &&
              req.status != LoanStatus.menunggu &&
              req.status != LoanStatus.pending) {
            continue;
          }
          final weekdayIdx = (req.submittedAt.weekday - 1).clamp(0, 6);
          counts[weekdayIdx] += 1;
        }
        return counts;

      case QueueChartPeriod.mingguan:
        // Baseline 5 minggu dalam bulan aktif
        final counts = [18, 26, 34, 21, 15];
        for (final req in rawRequests) {
          if (pendingOnly &&
              req.status != LoanStatus.menunggu &&
              req.status != LoanStatus.pending) {
            continue;
          }
          final day = req.submittedAt.day;
          final weekIdx = ((day - 1) ~/ 7).clamp(0, 4);
          counts[weekIdx] += 1;
        }
        return counts;

      case QueueChartPeriod.bulanan:
        // Baseline 12 bulan tahun berjalan
        final counts = [45, 52, 68, 55, 78, 85, 62, 74, 88, 59, 51, 40];
        for (final req in rawRequests) {
          if (pendingOnly &&
              req.status != LoanStatus.menunggu &&
              req.status != LoanStatus.pending) {
            continue;
          }
          final monthIdx = (req.submittedAt.month - 1).clamp(0, 11);
          counts[monthIdx] += 1;
        }
        return counts;
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 750;
    final chartData = _generateChartData();
    final maxVal = chartData.reduce((a, b) => a > b ? a : b);
    final totalInPeriod = chartData.reduce((a, b) => a + b);
    final avgInPeriod = (totalInPeriod / chartData.length).toStringAsFixed(1);

    // Cari titik puncak
    int peakIndex = 0;
    int peakValue = chartData[0];
    for (int i = 1; i < chartData.length; i++) {
      if (chartData[i] > peakValue) {
        peakValue = chartData[i];
        peakIndex = i;
      }
    }

    final peakLabel = switch (_selectedPeriod) {
      QueueChartPeriod.harian => _dailyFullLabels[peakIndex],
      QueueChartPeriod.mingguan => _weeklyFullLabels[peakIndex],
      QueueChartPeriod.bulanan => _monthlyFullLabels[peakIndex],
    };

    final pendingRequests = widget.requests
        .where(
          (r) =>
              r.status == LoanStatus.menunggu ||
              r.status == LoanStatus.pending,
        )
        .toList();

    final isDark = ThemeService.isDarkMode;
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
                  Icons.analytics_rounded,
                  color: Color(0xFFF59E0B),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Grafik Analisis Antrean',
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
              'Statistik & tren antrean armada',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.hourglass_empty_rounded,
                  color: Color(0xFFD97706),
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  isMobile
                      ? '${pendingRequests.length} Menunggu'
                      : '${pendingRequests.length} Berkas Menunggu',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Baris Filter Periode (Harian, Mingguan, Bulanan)
            _buildPeriodFilterBar(),
            const SizedBox(height: 16),

            // 2. Kartu Metrik Ringkas
            _buildSummaryMetricCards(
              totalInPeriod,
              avgInPeriod,
              peakLabel,
              peakValue,
              pendingRequests.length,
            ),
            const SizedBox(height: 18),

            // 3. Komponen Grafik Visual Bar Chart
            _buildChartCard(chartData, maxVal),
            const SizedBox(height: 18),

            // 4. Breakdown & Sebaran Data
            if (isMobile) ...[
              _buildDepartmentDistributionCard(),
              const SizedBox(height: 16),
              _buildVehicleTypeDistributionCard(),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildDepartmentDistributionCard(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: _buildVehicleTypeDistributionCard(),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // 5. Tabel / Daftar Berkas Antrean Aktif
            _buildPendingQueueList(pendingRequests),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilterBar() {
    final isDark = ThemeService.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Filter Periode
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Periode: ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 6),
              _buildPeriodButton(QueueChartPeriod.harian, 'Harian'),
              const SizedBox(width: 6),
              _buildPeriodButton(QueueChartPeriod.mingguan, 'Mingguan'),
              const SizedBox(width: 6),
              _buildPeriodButton(QueueChartPeriod.bulanan, 'Bulanan'),
            ],
          ),

          // Toggle Hanya Pending
          FilterChip(
            label: const Text('Hanya Status Menunggu'),
            selected: _onlyPending,
            onSelected: (val) {
              setState(() {
                _onlyPending = val;
                _selectedPointIndex = -1;
              });
            },
            selectedColor: const Color(0xFFFEF3C7),
            checkmarkColor: const Color(0xFFD97706),
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: _onlyPending ? FontWeight.bold : FontWeight.w500,
              color: _onlyPending
                  ? const Color(0xFFB45309)
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: _onlyPending
                    ? const Color(0xFFFDE68A)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(QueueChartPeriod period, String label) {
    final isDark = ThemeService.isDarkMode;
    final isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _selectedPointIndex = -1;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF24487A)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryMetricCards(
    int total,
    String avg,
    String peakLabel,
    int peakVal,
    int currentPending,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _buildMetricItem(
            'Total Pengajuan',
            total.toString(),
            'Berkas dalam periode',
            Icons.assignment_rounded,
            const Color(0xFF2563EB),
          ),
          _buildMetricItem(
            'Rata-rata Pengajuan',
            avg,
            switch (_selectedPeriod) {
              QueueChartPeriod.harian => 'Berkas per hari',
              QueueChartPeriod.mingguan => 'Berkas per minggu',
              QueueChartPeriod.bulanan => 'Berkas per bulan',
            },
            Icons.trending_up_rounded,
            const Color(0xFF0D9488),
          ),
          _buildMetricItem(
            'Titik Puncak (Peak)',
            '$peakVal Berkas',
            peakLabel,
            Icons.bar_chart_rounded,
            const Color(0xFFF59E0B),
          ),
          _buildMetricItem(
            'Antrean Aktif Saat Ini',
            currentPending.toString(),
            'Menunggu tindakan Kasubag',
            Icons.hourglass_bottom_rounded,
            const Color(0xFFEA580C),
          ),
        ];

        if (constraints.maxWidth < 650) {
          return Column(
            children: cards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: c,
                    ))
                .toList(),
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
      },
    );
  }

  Widget _buildMetricItem(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    final isDark = ThemeService.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.04),
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _handleChartTouch(
    Offset localPosition,
    double chartWidth,
    int count, {
    bool isTap = false,
  }) {
    if (count <= 1 || chartWidth <= 0) return;
    final horizontalPadding = count > 8 ? 16.0 : 24.0;
    final drawableWidth = chartWidth - horizontalPadding * 2;
    if (drawableWidth <= 0) return;

    final stepX = drawableWidth / (count - 1);
    final relativeX =
        (localPosition.dx - horizontalPadding).clamp(0.0, drawableWidth);
    final index = (relativeX / stepX).round().clamp(0, count - 1);

    setState(() {
      if (isTap && _selectedPointIndex == index) {
        _selectedPointIndex = -1; // toggle off
      } else {
        _selectedPointIndex = index;
      }
    });
  }

  Widget _buildChartCard(List<int> data, int maxVal) {
    final isDark = ThemeService.isDarkMode;
    final labels = switch (_selectedPeriod) {
      QueueChartPeriod.harian => _dailyLabels,
      QueueChartPeriod.mingguan => _weeklyLabels,
      QueueChartPeriod.bulanan => _monthlyLabels,
    };

    final fullLabels = switch (_selectedPeriod) {
      QueueChartPeriod.harian => _dailyFullLabels,
      QueueChartPeriod.mingguan => _weeklyFullLabels,
      QueueChartPeriod.bulanan => _monthlyFullLabels,
    };

    final safeMax = maxVal == 0 ? 1 : maxVal;
    final primaryColor = _onlyPending
        ? const Color(0xFFF59E0B)
        : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB));
    final secondaryColor = _onlyPending
        ? const Color(0xFFEF4444)
        : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF06B6D4));

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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Grafik
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafik Tren Permohonan (${switch (_selectedPeriod) {
                        QueueChartPeriod.harian => '7 Hari Terakhir',
                        QueueChartPeriod.mingguan => 'Bulan Ini / Minggu',
                        QueueChartPeriod.bulanan => 'Tahun 2026 / Bulan',
                      }})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ketuk garis atau titik untuk melihat jumlah berkas dan rincian.',
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 13,
                      color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Grafik Garis',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Komponen Grafik Garis Interaktif
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  _handleChartTouch(
                    details.localPosition,
                    chartWidth,
                    data.length,
                    isTap: true,
                  );
                },
                onHorizontalDragUpdate: (details) {
                  _handleChartTouch(
                    details.localPosition,
                    chartWidth,
                    data.length,
                    isTap: false,
                  );
                },
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('${_selectedPeriod.name}_$_onlyPending'),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, _) {
                    return CustomPaint(
                      size: Size(chartWidth, 205),
                      painter: _LineChartPainter(
                        data: data,
                        maxVal: safeMax,
                        selectedIndex: _selectedPointIndex,
                        labels: labels,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        secondaryColor: secondaryColor,
                        animationProgress: progress,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Divider(
            height: 16,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),

          // Info Card Saat Salah Satu Titik Dipilih
          if (_selectedPointIndex != -1 && _selectedPointIndex < data.length)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.5)
                      : const Color(0xFFBFDBFE),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        children: [
                          const TextSpan(text: 'Rincian '),
                          TextSpan(
                            text: fullLabels[_selectedPointIndex],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ': Terdata total '),
                          TextSpan(
                            text: '${data[_selectedPointIndex]} berkas permohonan',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' yang masuk ke antrean verifikasi operasional dinas.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 14),
                    onPressed: () => setState(() => _selectedPointIndex = -1),
                    color: const Color(0xFF64748B),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            )
          else
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded, size: 14, color: Color(0xFF94A3B8)),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Ketuk garis grafik untuk melihat jumlah dan rincian permohonan.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDepartmentDistributionCard() {
    final isDark = ThemeService.isDarkMode;
    // Hitung bidang pemohon
    final deptCount = <String, int>{};
    for (final r in widget.requests) {
      final dept = r.department.isNotEmpty ? r.department : 'Dinsos Jatim';
      deptCount[dept] = (deptCount[dept] ?? 0) + 1;
    }

    // Default mock distribution jika data masih sedikit
    final defaultDistribution = {
      'Subbag Penyusunan Program & Anggaran': 18,
      'Bidang Perlindungan & Jaminan Sosial (Linjamsos)': 26,
      'Bidang Rehabilitasi Sosial (Rehsos)': 19,
      'Bidang Penanganan Fakir Miskin (PFM)': 15,
      'Subbag Keuangan & Aset': 12,
    };

    // Gabungkan data riil
    for (final entry in deptCount.entries) {
      defaultDistribution[entry.key] =
          (defaultDistribution[entry.key] ?? 0) + entry.value;
    }

    final totalRequests =
        defaultDistribution.values.fold(0, (acc, val) => acc + val);

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
                'Sebaran Antrean per Bidang / Unit',
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
          for (final entry in defaultDistribution.entries) ...[
            _buildDistributionRow(entry.key, entry.value, totalRequests),
            if (entry.key != defaultDistribution.keys.last)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildDistributionRow(String title, int count, int total) {
    final isDark = ThemeService.isDarkMode;
    final percent = total == 0 ? 0.0 : (count / total);
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
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$count Berkas (${(percent * 100).toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(
              percent > 0.25
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeDistributionCard() {
    final isDark = ThemeService.isDarkMode;
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
            'Kategori Armada Diminta',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildTypeStatItem(
            'Mobil Operasional (MPV/SUV/Minibus)',
            '82%',
            Icons.directions_car_rounded,
            const Color(0xFF2563EB),
          ),
          Divider(
            height: 20,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
          _buildTypeStatItem(
            'Sepeda Motor Pool Lapangan',
            '18%',
            Icons.two_wheeler_rounded,
            const Color(0xFF10B981),
          ),
          Divider(
            height: 20,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.speed_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Armada favorit tertinggi: Toyota Innova Reborn & Veloz.',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStatItem(
    String label,
    String percent,
    IconData icon,
    Color color,
  ) {
    final isDark = ThemeService.isDarkMode;
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
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
        ),
        Text(
          percent,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingQueueList(List<LoanRequest> pendingList) {
    final isDark = ThemeService.isDarkMode;
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
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.pending_actions_rounded,
                      color: Color(0xFFF59E0B),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Antrean Menunggu Tindakan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${pendingList.length} Berkas',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (pendingList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF16A34A),
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Antrean Masuk Bersih!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Semua permohonan peminjaman armada telah diverifikasi.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingList.length,
              separatorBuilder: (context, index) =>
                  Divider(
                    height: 16,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
              itemBuilder: (context, index) {
                final item = pendingList[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: Color(0xFFD97706),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.borrowerName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatDate(item.submittedAt),
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
                              fontSize: 11,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
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
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.onVerify != null) {
                          LoanDetailDialog.show(
                            context,
                            loan: item,
                            onVerify: (loan, isApproved) {
                              widget.onVerify!(loan, isApproved);
                              setState(() {});
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24487A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Verifikasi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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

/// Custom painter untuk grafik garis tren antrean interaktif.
/// Desain rapi tanpa angka di atas titik saat kondisi normal (clean minimalist).
/// Saat titik atau garis disentuh/diklik, muncul efek glow, garis pandu vertikal,
/// dan floating tooltip pill dengan angka berkas yang presisi.
class _LineChartPainter extends CustomPainter {
  final List<int> data;
  final int maxVal;
  final int selectedIndex;
  final List<String> labels;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;
  final double animationProgress;

  _LineChartPainter({
    required this.data,
    required this.maxVal,
    required this.selectedIndex,
    required this.labels,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final count = data.length;
    final horizontalPadding = count > 8 ? 16.0 : 24.0;
    const topPadding = 38.0;
    const bottomPadding = 28.0; // Ruang untuk label X-axis di bagian bawah
    final drawableWidth = size.width - (horizontalPadding * 2);
    final drawableHeight = size.height - topPadding - bottomPadding;

    if (drawableWidth <= 0 || drawableHeight <= 0) return;

    final safeMax = maxVal <= 0 ? 1 : maxVal;
    final baselineY = size.height - bottomPadding;

    // 1. Garis Kisi Horizontal (Subtle Gridlines)
    const gridLineCount = 4;
    final gridPaint = Paint()
      ..color = (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
          .withValues(alpha: 0.7)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= gridLineCount; i++) {
      final y = topPadding + (drawableHeight * i / gridLineCount);
      double startX = horizontalPadding;
      const dashWidth = 4.0;
      const dashSpace = 4.0;
      while (startX < size.width - horizontalPadding) {
        final endX =
            (startX + dashWidth).clamp(startX, size.width - horizontalPadding);
        canvas.drawLine(Offset(startX, y), Offset(endX, y), gridPaint);
        startX += dashWidth + dashSpace;
      }
    }

    // 2. Hitung Posisi Titik-titik (Points)
    final stepX = count > 1 ? drawableWidth / (count - 1) : drawableWidth;
    final points = <Offset>[];
    for (int i = 0; i < count; i++) {
      final x = horizontalPadding + (i * stepX);
      final normalizedValue = (data[i] / safeMax).clamp(0.0, 1.0);
      final y =
          baselineY - (normalizedValue * drawableHeight * animationProgress);
      points.add(Offset(x, y));
    }

    // 3. Bangun Kurva Bezier Mulus (Catmull-Rom to Cubic Bezier)
    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      if (points.length == 1) {
        path.lineTo(size.width - horizontalPadding, points[0].dy);
      } else {
        for (int i = 0; i < points.length - 1; i++) {
          final p0 = i > 0 ? points[i - 1] : points[i];
          final p1 = points[i];
          final p2 = points[i + 1];
          final p3 = i < points.length - 2 ? points[i + 2] : p2;

          final cp1x = p1.dx + (p2.dx - p0.dx) / 5.5;
          final cp1y = p1.dy + (p2.dy - p0.dy) / 5.5;
          final cp2x = p2.dx - (p3.dx - p1.dx) / 5.5;
          final cp2y = p2.dy - (p3.dy - p1.dy) / 5.5;

          path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
        }
      }
    }

    // 4. Area Gradient Fill di Bawah Garis
    if (points.length > 1) {
      final fillPath = Path.from(path);
      fillPath.lineTo(points.last.dx, baselineY);
      fillPath.lineTo(points.first.dx, baselineY);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: isDark ? 0.35 : 0.22),
            secondaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
            primaryColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(
            Rect.fromLTWH(0, topPadding, size.width, drawableHeight));

      canvas.drawPath(fillPath, fillPaint);
    }

    // 5. Garis Stroke Bergradasi (Glow & Main Line)
    final strokeShader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [primaryColor, secondaryColor],
    ).createShader(
      Rect.fromLTWH(horizontalPadding, 0, drawableWidth, size.height),
    );

    // Efek glowing tipis di bawah garis
    final glowPaint = Paint()
      ..shader = strokeShader
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);

    // Garis utama
    final linePaint = Paint()
      ..shader = strokeShader
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // 6. Titik-titik Node Biasa (Bersih tanpa angka)
    for (int i = 0; i < points.length; i++) {
      if (i == selectedIndex) continue;
      final pt = points[i];

      final backPaint = Paint()
        ..color = isDark ? const Color(0xFF1E293B) : Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, 4.5, backPaint);

      final ringPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.85)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pt, 4.0, ringPaint);

      final corePaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, 2.0, corePaint);
    }

    // 7. Label X-Axis (Tanggal/Hari/Bulan tepat di bawah node)
    final labelY = size.height - 18;
    for (int i = 0; i < points.length; i++) {
      final isSelected = i == selectedIndex;
      final label = labels[i];
      final labelColor = isSelected
          ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8))
          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: count > 8 ? 9.5 : 10.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: labelColor,
          letterSpacing: count > 8 ? -0.2 : 0.0,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelX = points[i].dx - (textPainter.width / 2);

      if (isSelected) {
        final pillRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(points[i].dx, labelY + (textPainter.height / 2)),
            width: textPainter.width + 12,
            height: textPainter.height + 4,
          ),
          const Radius.circular(6),
        );
        canvas.drawRRect(
          pillRect,
          Paint()
            ..color =
                (isDark ? const Color(0xFF2563EB) : const Color(0xFFDBEAFE))
                    .withValues(alpha: 0.5),
        );
      }

      textPainter.paint(canvas, Offset(labelX, labelY));
    }

    // 8. Titik Terpilih yang Diklik: Guideline, Glow Rings, & Floating Tooltip Angka
    if (selectedIndex >= 0 && selectedIndex < points.length) {
      final selPt = points[selectedIndex];
      final val = data[selectedIndex];

      // 8a. Garis Pandu Vertikal Putus-putus
      final guidePaint = Paint()
        ..color = primaryColor.withValues(alpha: isDark ? 0.55 : 0.45)
        ..strokeWidth = 1.5;

      double gStartY = topPadding;
      const gDashHeight = 4.0;
      const gDashSpace = 3.0;
      while (gStartY < baselineY) {
        final gEndY = (gStartY + gDashHeight).clamp(topPadding, baselineY);
        canvas.drawLine(
          Offset(selPt.dx, gStartY),
          Offset(selPt.dx, gEndY),
          guidePaint,
        );
        gStartY += gDashHeight + gDashSpace;
      }

      // 8b. Cincin Efek Glow pada Titik Terpilih
      canvas.drawCircle(
        selPt,
        14.0,
        Paint()..color = primaryColor.withValues(alpha: isDark ? 0.28 : 0.20),
      );
      canvas.drawCircle(
        selPt,
        8.5,
        Paint()..color = primaryColor.withValues(alpha: isDark ? 0.5 : 0.35),
      );
      canvas.drawCircle(
        selPt,
        6.0,
        Paint()
          ..color = isDark ? const Color(0xFF0F172A) : Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        selPt,
        4.0,
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill,
      );

      // 8c. Tooltip Pill Menampilkan Angka
      final tooltipTextSpan = TextSpan(
        children: [
          TextSpan(
            text: '$val',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const TextSpan(
            text: ' Berkas',
            style: TextStyle(
              color: Color(0xFFBFDBFE),
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
      final tooltipPainter = TextPainter(
        text: tooltipTextSpan,
        textDirection: TextDirection.ltr,
      );
      tooltipPainter.layout();

      const pillPaddingH = 10.0;
      const pillPaddingV = 5.0;
      final pillWidth = tooltipPainter.width + (pillPaddingH * 2);
      final pillHeight = tooltipPainter.height + (pillPaddingV * 2);

      // Tentukan posisi vertikal tooltip (di atas jika muat, atau di bawah)
      final showAbove = (selPt.dy - pillHeight - 12) >= 4.0;
      final pillY =
          showAbove ? (selPt.dy - pillHeight - 10) : (selPt.dy + 12);

      // Pastikan tooltip tidak terpotong di tepi layar
      final pillX =
          (selPt.dx - (pillWidth / 2)).clamp(6.0, size.width - pillWidth - 6.0);

      final pillRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pillX, pillY, pillWidth, pillHeight),
        const Radius.circular(8),
      );

      // Shadow bayangan tooltip
      canvas.drawRRect(
        pillRRect.shift(const Offset(0, 3)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Latar belakang tooltip
      final pillBgPaint = Paint()
        ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(pillRRect, pillBgPaint);

      // Border tooltip
      final pillBorderPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.75)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(pillRRect, pillBorderPaint);

      // Segitiga penunjuk (pointer arrow)
      final arrowX = selPt.dx.clamp(pillX + 8.0, pillX + pillWidth - 8.0);
      final arrowPath = Path();
      if (showAbove) {
        arrowPath.moveTo(arrowX - 5, pillY + pillHeight);
        arrowPath.lineTo(arrowX + 5, pillY + pillHeight);
        arrowPath.lineTo(arrowX, pillY + pillHeight + 5);
        arrowPath.close();
      } else {
        arrowPath.moveTo(arrowX - 5, pillY);
        arrowPath.lineTo(arrowX + 5, pillY);
        arrowPath.lineTo(arrowX, pillY - 5);
        arrowPath.close();
      }
      canvas.drawPath(arrowPath, pillBgPaint);
      canvas.drawPath(arrowPath, pillBorderPaint);

      // Gambar teks angka di dalam tooltip
      tooltipPainter.paint(
        canvas,
        Offset(
          pillX + ((pillWidth - tooltipPainter.width) / 2),
          pillY + ((pillHeight - tooltipPainter.height) / 2),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.data != data;
  }
}

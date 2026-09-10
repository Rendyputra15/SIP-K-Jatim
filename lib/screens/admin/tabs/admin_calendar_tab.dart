import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class AdminCalendarTab extends StatefulWidget {
  final List<LoanRequest> requests;
  final List<Vehicle> vehicles;

  const AdminCalendarTab({
    super.key,
    required this.requests,
    required this.vehicles,
  });

  @override
  State<AdminCalendarTab> createState() => _AdminCalendarTabState();
}

class _AdminCalendarTabState extends State<AdminCalendarTab> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  String _selectedTypeFilter = 'Semua';

  bool get isDark => ThemeService.isDarkMode;

  final List<String> _monthNames = const [
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

  final List<String> _dayNames = const [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  final List<String> _fullDayNames = const [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _displayedMonth = DateTime(now.year, now.month, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isLoanOnDate(LoanRequest loan, DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      loan.startDate.year,
      loan.startDate.month,
      loan.startDate.day,
    );
    final end = DateTime(
      loan.endDate.year,
      loan.endDate.month,
      loan.endDate.day,
    );
    return !target.isBefore(start) && !target.isAfter(end);
  }

  List<LoanRequest> _getLoansForDate(DateTime date) {
    return widget.requests.where((r) => _isLoanOnDate(r, date)).toList();
  }

  String _formatDateString(DateTime date) {
    final dayName = _fullDayNames[date.weekday - 1];
    return '$dayName, ${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  String _formatRangeDate(DateTime start, DateTime end) {
    if (_isSameDay(start, end)) {
      return '${start.day} ${_monthNames[start.month - 1]} ${start.year}';
    }
    return '${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 850;
    final loansForSelectedDate = _getLoansForDate(_selectedDate);

    final filteredLoans = loansForSelectedDate.where((l) {
      if (_selectedTypeFilter == 'Semua') return true;
      final vehicle = widget.vehicles.where((v) => v.id == l.vehicleId).firstOrNull;
      if (vehicle == null) {
        if (_selectedTypeFilter == 'Mobil') {
          return !l.vehicleName.toLowerCase().contains('vario') &&
              !l.vehicleName.toLowerCase().contains('nmax') &&
              !l.vehicleName.toLowerCase().contains('beat') &&
              !l.vehicleName.toLowerCase().contains('motor');
        } else {
          return l.vehicleName.toLowerCase().contains('vario') ||
              l.vehicleName.toLowerCase().contains('nmax') ||
              l.vehicleName.toLowerCase().contains('beat') ||
              l.vehicleName.toLowerCase().contains('motor');
        }
      }
      if (_selectedTypeFilter == 'Mobil') return vehicle.type == VehicleType.mobil;
      if (_selectedTypeFilter == 'Motor') return vehicle.type == VehicleType.motor;
      return true;
    }).toList();

    // Hitung armada bertugas vs tersedia pada hari terpilih
    final bookedVehicleNames = loansForSelectedDate
        .where(
          (l) =>
              l.status == LoanStatus.disetujui ||
              l.status == LoanStatus.approved ||
              l.status == LoanStatus.selesai,
        )
        .map((l) => l.vehicleName.toLowerCase())
        .toSet();

    final totalVehicles = widget.vehicles.length;
    final busyVehiclesCount = widget.vehicles.where((v) {
      return bookedVehicleNames.contains(v.name.toLowerCase()) ||
          bookedVehicleNames.any((name) => name.contains(v.name.toLowerCase()));
    }).length;
    final availableVehiclesCount = (totalVehicles - busyVehiclesCount).clamp(0, totalVehicles);

    final pendingCount = loansForSelectedDate
        .where((l) => l.status == LoanStatus.menunggu || l.status == LoanStatus.pending)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner Superadmin (Overflow Fix & Aesthetic Design)
          _buildHeaderBanner(),
          const SizedBox(height: 16),

          // 2. Kalender & Jadwal Detail
          if (isMobile) ...[
            _buildCalendarCard(),
            const SizedBox(height: 16),
            _buildScheduleDetailCard(
              filteredLoans,
              busyVehiclesCount,
              availableVehiclesCount,
              pendingCount,
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildCalendarCard(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: _buildScheduleDetailCard(
                    filteredLoans,
                    busyVehiclesCount,
                    availableVehiclesCount,
                    pendingCount,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 1. HEADER BANNER UTAMA (SUPERADMIN)
  Widget _buildHeaderBanner() {
    final now = DateTime.now();
    final isTodaySelected = _isSameDay(_selectedDate, now);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isDark ? const Color(0xFF3B82F6) : const Color(0xFF24487A),
                width: 5,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 480;

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E3A8A).withValues(alpha: 0.5)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2563EB).withValues(alpha: 0.4)
                                : const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF24487A),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jadwal & Kalender Armada',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pantau ketersediaan, reservasi aktif, dan penugasan armada harian.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                height: 1.3,
                              ),
                              maxLines: isCompact ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (!isCompact) ...[
                        const SizedBox(width: 12),
                        _buildTodayButton(isTodaySelected),
                      ],
                    ],
                  ),
                  if (isCompact) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _buildTodayButton(isTodaySelected),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTodayButton(bool isTodaySelected) {
    return ElevatedButton.icon(
      onPressed: _jumpToToday,
      icon: Icon(
        Icons.today_rounded,
        size: 16,
        color: isTodaySelected ? Colors.white : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A)),
      ),
      label: Text(
        'Hari Ini',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isTodaySelected ? Colors.white : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A)),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isTodaySelected
            ? const Color(0xFF24487A)
            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
        elevation: isTodaySelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isTodaySelected
                ? const Color(0xFF24487A)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
        ),
      ),
    );
  }

  // 2. KARTU KALENDER INTERAKTIF & MODERN
  Widget _buildCalendarCard() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    final startingWeekday = firstDayOfMonth.weekday; // 1-7 (Senin-Minggu)
    final prevMonthDays = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      0,
    ).day;

    final totalGridCells = (startingWeekday - 1 + daysInMonth > 35) ? 42 : 35;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigasi Bulan & Tahun
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      size: 18,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildNavIconButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _previousMonth,
                    tooltip: 'Bulan Sebelumnya',
                  ),
                  const SizedBox(width: 6),
                  _buildNavIconButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _nextMonth,
                    tooltip: 'Bulan Berikutnya',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header Hari (Sen - Min) dengan background container tipis
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: _dayNames.map((d) {
                final isWeekend = d == 'Sab' || d == 'Min';
                return Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isWeekend
                            ? const Color(0xFFEF4444)
                            : (isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Grid Tanggal
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalGridCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              DateTime cellDate;
              bool isCurrentMonth = true;

              if (index < startingWeekday - 1) {
                final prevDay = prevMonthDays - (startingWeekday - 2 - index);
                cellDate = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month - 1,
                  prevDay,
                );
                isCurrentMonth = false;
              } else if (index >= startingWeekday - 1 + daysInMonth) {
                final nextDay = index - (startingWeekday - 1 + daysInMonth) + 1;
                cellDate = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month + 1,
                  nextDay,
                );
                isCurrentMonth = false;
              } else {
                final dayNumber = index - startingWeekday + 2;
                cellDate = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month,
                  dayNumber,
                );
              }

              final isSelected = _isSameDay(cellDate, _selectedDate);
              final isToday = _isSameDay(cellDate, today);
              final loansOnDay = _getLoansForDate(cellDate);
              
              final hasApproved = loansOnDay.any(
                (l) =>
                    l.status == LoanStatus.disetujui ||
                    l.status == LoanStatus.approved ||
                    l.status == LoanStatus.selesai,
              );
              final hasPending = loansOnDay.any(
                (l) =>
                    l.status == LoanStatus.menunggu ||
                    l.status == LoanStatus.pending,
              );

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = cellDate;
                    if (!isCurrentMonth) {
                      _displayedMonth = DateTime(
                        cellDate.year,
                        cellDate.month,
                        1,
                      );
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF24487A)
                        : (isToday
                            ? (isDark
                                ? const Color(0xFF1E3A8A).withValues(alpha: 0.45)
                                : const Color(0xFFEFF6FF))
                            : (isCurrentMonth
                                ? (isDark
                                    ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                                    : Colors.transparent)
                                : Colors.transparent)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E3A8A)
                          : (isToday
                              ? const Color(0xFF3B82F6)
                              : (isDark
                                  ? const Color(0xFF334155).withValues(alpha: 0.5)
                                  : const Color(0xFFF1F5F9))),
                      width: isToday && !isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF24487A).withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${cellDate.day}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w900
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isCurrentMonth
                                  ? (cellDate.weekday >= 6
                                      ? const Color(0xFFEF4444)
                                      : (isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B)))
                                  : (isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFFCBD5E1))),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Indikator Titik Status Penugasan
                      if (loansOnDay.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasApproved)
                              Container(
                                width: 5.5,
                                height: 5.5,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasPending)
                              Container(
                                width: 5.5,
                                height: 5.5,
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFBBF24)
                                      : const Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        )
                      else
                        const SizedBox(height: 5.5),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 12),

          // Legenda Status Kalender (Clean Pill Style)
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendPill(
                color: const Color(0xFF16A34A),
                label: 'Armada Bertugas',
              ),
              _buildLegendPill(
                color: const Color(0xFFF59E0B),
                label: 'Menunggu Verifikasi',
              ),
              _buildLegendPill(
                color: const Color(0xFF3B82F6),
                label: 'Hari Ini',
                isBorderOnly: true,
              ),
              _buildLegendPill(
                color: const Color(0xFF24487A),
                label: 'Tanggal Dipilih',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendPill({
    required Color color,
    required String label,
    bool isBorderOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isBorderOnly ? Colors.transparent : color,
              shape: BoxShape.circle,
              border: isBorderOnly ? Border.all(color: color, width: 2) : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // 3. KARTU DETAIL JADWAL TUGAS ARMADA HARI TERPILIH
  Widget _buildScheduleDetailCard(
    List<LoanRequest> loans,
    int busyVehicles,
    int availableVehicles,
    int pendingCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tanggal Terpilih & Indicator Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateString(_selectedDate),
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${loans.length} Berkas Penugasan Terdaftar',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Indicator Status Armada Ringkas
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF16A34A), size: 7),
                    const SizedBox(width: 5),
                    Text(
                      '$availableVehicles Siap',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.circle, color: Color(0xFF2563EB), size: 7),
                    const SizedBox(width: 5),
                    Text(
                      '$busyVehicles Jalan',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filter Tipe Armada Segmented Control (Semua / Mobil / Motor)
          Row(
            children: ['Semua', 'Mobil', 'Motor'].map((type) {
              final isSelected = _selectedTypeFilter == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedTypeFilter = type),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF24487A)
                          : (isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF24487A)
                            : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Divider(
            height: 24,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),

          // Daftar Penugasan pada Hari Tersebut
          if (loans.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 36,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.event_available_rounded,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak Ada Jadwal Penugasan',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seluruh armada dinas siap & dapat diajukan pada tanggal ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
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
              itemCount: loans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = loans[index];
                return _buildScheduleItemCard(item);
              },
            ),
        ],
      ),
    );
  }

  // 4. KARTU PENUGASAN INDIVIDUAL
  Widget _buildScheduleItemCard(LoanRequest item) {
    Color badgeBg;
    Color badgeColor;
    String statusLabel;

    switch (item.status) {
      case LoanStatus.disetujui:
      case LoanStatus.approved:
        badgeBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
        badgeColor =
            isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
        statusLabel = 'Disetujui / Jalan';
        break;
      case LoanStatus.selesai:
        badgeBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
        badgeColor =
            isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB);
        statusLabel = 'Selesai (BAST)';
        break;
      case LoanStatus.ditolak:
      case LoanStatus.rejected:
        badgeBg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        badgeColor =
            isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
        statusLabel = 'Ditolak';
        break;
      default:
        badgeBg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        badgeColor =
            isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        statusLabel = 'Menunggu Verifikasi';
    }

    final isCar = !item.vehicleName.toLowerCase().contains('vario') &&
        !item.vehicleName.toLowerCase().contains('nmax') &&
        !item.vehicleName.toLowerCase().contains('beat') &&
        !item.vehicleName.toLowerCase().contains('motor');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Avatar Armada
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Icon(
              isCar ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Detail Berkas & Pemohon
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.vehicleName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
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
                        statusLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pemohon: ${item.borrowerName} (${item.department})',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        item.destination,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        size: 12,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF24487A),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Periode: ${_formatRangeDate(item.startDate, item.endDate)}',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF24487A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

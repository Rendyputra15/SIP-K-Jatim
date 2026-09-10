import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';

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
        // Cek lewat nama kendaraan bila ID tidak persis
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner & Navigasi Cepat
          _buildHeaderBanner(),
          const SizedBox(height: 18),

          // 2. Kalender & Jadwal Detail
          if (isMobile) ...[
            _buildCalendarCard(),
            const SizedBox(height: 18),
            _buildScheduleDetailCard(
              filteredLoans,
              busyVehiclesCount,
              availableVehiclesCount,
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildCalendarCard(),
                ),
                const SizedBox(width: 18),
                Expanded(
                  flex: 6,
                  child: _buildScheduleDetailCard(
                    filteredLoans,
                    busyVehiclesCount,
                    availableVehiclesCount,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF24487A),
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Jadwal & Kalender Armada',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Pantau ketersediaan, reservasi aktif, dan penugasan armada dinas harian.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _jumpToToday,
            icon: const Icon(Icons.today_rounded, size: 16),
            label: const Text(
              'Hari Ini',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24487A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Hitung hari awal bulan dan total hari dalam bulan
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

    // Hari dalam seminggu: 1 = Senin, 7 = Minggu
    final startingWeekday = firstDayOfMonth.weekday; // 1-7
    final prevMonthDays = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      0,
    ).day;

    final totalGridCells = (startingWeekday - 1 + daysInMonth > 35) ? 42 : 35;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bulan & Navigasi Prev/Next
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 24),
                onPressed: _previousMonth,
                tooltip: 'Bulan Sebelumnya',
                color: const Color(0xFF1E293B),
              ),
              Text(
                '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 24),
                onPressed: _nextMonth,
                tooltip: 'Bulan Berikutnya',
                color: const Color(0xFF1E293B),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Baris Nama Hari (Sen - Min)
          Row(
            children: _dayNames.map((d) {
              final isWeekend = d == 'Sab' || d == 'Min';
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isWeekend
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

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
                // Hari dari bulan sebelumnya
                final prevDay = prevMonthDays - (startingWeekday - 2 - index);
                cellDate = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month - 1,
                  prevDay,
                );
                isCurrentMonth = false;
              } else if (index >= startingWeekday - 1 + daysInMonth) {
                // Hari dari bulan berikutnya
                final nextDay = index - (startingWeekday - 1 + daysInMonth) + 1;
                cellDate = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month + 1,
                  nextDay,
                );
                isCurrentMonth = false;
              } else {
                // Hari di bulan aktif
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF24487A)
                        : (isToday
                            ? const Color(0xFFEFF6FF)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && !isSelected
                        ? Border.all(color: const Color(0xFF3B82F6), width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${cellDate.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w900
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isCurrentMonth
                                  ? (cellDate.weekday >= 6
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF1E293B))
                                  : const Color(0xFFCBD5E1)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Indikator Titik Jadwal
                      if (loansOnDay.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasApproved)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasPending)
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
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
                        const SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Keterangan Legenda
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(const Color(0xFF16A34A), 'Armada Bertugas'),
              _buildLegendItem(const Color(0xFFF59E0B), 'Menunggu Verifikasi'),
              _buildLegendItem(const Color(0xFF24487A), 'Tanggal Dipilih'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildScheduleDetailCard(
    List<LoanRequest> loans,
    int busyVehicles,
    int availableVehicles,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          // Tanggal Terpilih & Badge Ketersediaan
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${loans.length} Berkas Penugasan Terjadwal',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              // Chip Ketersediaan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF16A34A), size: 8),
                    const SizedBox(width: 6),
                    Text(
                      '$availableVehicles Siap',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                    const SizedBox(width: 8),
                    const Icon(Icons.circle, color: Color(0xFF2563EB), size: 8),
                    const SizedBox(width: 6),
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
          const SizedBox(height: 16),

          // Filter Tipe Armada (Semua / Mobil / Motor)
          Row(
            children: ['Semua', 'Mobil', 'Motor'].map((type) {
              final isSelected = _selectedTypeFilter == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    type,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF24487A),
                  backgroundColor: const Color(0xFFF1F5F9),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF24487A)
                          : Colors.transparent,
                    ),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedTypeFilter = type);
                  },
                ),
              );
            }).toList(),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          // Daftar Kartu Tugas pada Hari Tersebut
          if (loans.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        color: Color(0xFF94A3B8),
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak Ada Jadwal Tugas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Seluruh armada dinas tersedia untuk diajukan pada tanggal ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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

  Widget _buildScheduleItemCard(LoanRequest item) {
    Color badgeBg;
    Color badgeColor;
    String statusLabel;

    switch (item.status) {
      case LoanStatus.disetujui:
      case LoanStatus.approved:
        badgeBg = const Color(0xFFDCFCE7);
        badgeColor = const Color(0xFF16A34A);
        statusLabel = 'Disetujui / Jalan';
        break;
      case LoanStatus.selesai:
        badgeBg = const Color(0xFFDBEAFE);
        badgeColor = const Color(0xFF2563EB);
        statusLabel = 'Tuntas (BAST)';
        break;
      case LoanStatus.ditolak:
      case LoanStatus.rejected:
        badgeBg = const Color(0xFFFEE2E2);
        badgeColor = const Color(0xFFDC2626);
        statusLabel = 'Ditolak';
        break;
      default:
        badgeBg = const Color(0xFFFEF3C7);
        badgeColor = const Color(0xFFD97706);
        statusLabel = 'Menunggu';
    }

    final isCar = !item.vehicleName.toLowerCase().contains('vario') &&
        !item.vehicleName.toLowerCase().contains('nmax') &&
        !item.vehicleName.toLowerCase().contains('beat') &&
        !item.vehicleName.toLowerCase().contains('motor');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Avatar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Icon(
              isCar ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
              color: const Color(0xFF24487A),
              size: 20,
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
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
                        statusLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Pemohon: ${item.borrowerName} (${item.department})',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        item.destination,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.date_range_rounded,
                        size: 11,
                        color: Color(0xFF24487A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Periode: ${_formatRangeDate(item.startDate, item.endDate)}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF24487A),
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

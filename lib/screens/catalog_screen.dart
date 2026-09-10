import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/screens/vehicle_detail_screen.dart';
import 'package:simodis_jatim/widgets/app_image.dart';
import 'package:simodis_jatim/widgets/app_header_profile_avatar.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class CatalogScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Function(Vehicle) onSelectVehicle;
  final Function(int)? onNavigateTab;

  const CatalogScreen({
    super.key,
    required this.vehicles,
    required this.onSelectVehicle,
    this.onNavigateTab,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _wheelFilter = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildVehicleImage(String imageUrl, VehicleType type) {
    return AppImage(
      source: imageUrl,
      fit: BoxFit.cover,
      placeholder: _buildPlaceholderIcon(type),
    );
  }

  Widget _buildPlaceholderIcon(VehicleType type) {
    return Center(
      child: Icon(
        type == VehicleType.mobil
            ? Icons.directions_car_filled
            : Icons.two_wheeler_rounded,
        size: 36,
        color: const Color(0xFF24487A),
      ),
    );
  }

  // Chip Indikator Sisa BBM (Bahan Bakar)
  Widget _buildFuelChip(Vehicle item, bool isDark) {
    Color bg;
    Color fg;
    Color border;

    if (item.fuelPercent >= 75) {
      bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
      fg = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF15803D);
      border = isDark ? const Color(0xFF047857) : const Color(0xFF86EFAC);
    } else if (item.fuelPercent >= 40) {
      bg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
      fg = isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309);
      border = isDark ? const Color(0xFFB45309) : const Color(0xFFFCD34D);
    } else {
      bg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
      fg = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
      border = isDark ? const Color(0xFFB91C1C) : const Color(0xFFFCA5A5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_gas_station_rounded, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            '${item.fuelDisplay} • ${item.fuelType}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  // Chip Indikator Transmisi (Matic / Manual)
  Widget _buildTransmissionChip(String transmission, bool isDark) {
    final bg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
    final fg = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
    final border = isDark ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tune_rounded, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            transmission,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  // Chip Indikator Odometer
  Widget _buildOdometerChip(int odo, bool isDark) {
    final bg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final fg = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final border = isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed_rounded, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            '$odo KM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;

    // Filter Armada berdasarkan tipe roda dan pencarian langsung (nama / nomor plat)
    final filteredList = widget.vehicles.where((v) {
      if (_wheelFilter == 'Roda 4' && v.type != VehicleType.mobil) return false;
      if (_wheelFilter == 'Roda 2' && v.type != VehicleType.motor) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = v.name.toLowerCase().contains(q);
        final matchPlate = v.plateNumber.toLowerCase().contains(q);
        final matchBrand = v.brand.toLowerCase().contains(q);
        if (!matchName && !matchPlate && !matchBrand) return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      // 1. HEADER UTAMA
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Katalog Armada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pilih unit operasional dinas',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppHeaderProfileAvatar(
                  onTap: () => widget.onNavigateTab?.call(4),
                ),
              ],
            ),
          ),
        ),
      ),
      // 2. KONTEN BODY
      body: Column(
        children: [
          // Bilah Pencarian Langsung (Nama Unit / Nomor Plat)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
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
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'Cari nama armada atau plat nomor (cth. Innova, L 1023 SP)...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),

          // Baris Info Hasil & Dropdown Filter Tipe Roda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info Jumlah Armada yang Ditemukan
                Text(
                  '${filteredList.length} unit armada tersedia',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),

                // Dropdown Filter Roda
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _wheelFilter,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                        size: 16,
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                      ),
                      items: ['Semua', 'Roda 2', 'Roda 4']
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _wheelFilter = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Card Kendaraan
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF24487A),
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 750));
                if (mounted) setState(() {});
              },
              child: filteredList.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 40,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Armada Tidak Ditemukan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Tidak ada kendaraan dengan kata kunci "$_searchQuery".'
                                    : 'Tidak ada kendaraan pada filter "$_wheelFilter".',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty || _wheelFilter != 'Semua') ...[
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _wheelFilter = 'Semua';
                                    });
                                  },
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: const Text('Reset Pencarian & Filter'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF24487A),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final isAvailable = item.status == VehicleStatus.tersedia;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar Thumbnail Armada
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 88,
                                      height: 84,
                                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
                                      child: _buildVehicleImage(
                                        item.imageUrl,
                                        item.type,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Info Detail & Chip Indikator
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Baris Nama & Status Badge
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isAvailable
                                                    ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7))
                                                    : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2)),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                isAvailable ? 'TERSEDIA' : 'DIPAKAI',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: isAvailable
                                                      ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF15803D))
                                                      : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),

                                        // Nomor Plat
                                        Text(
                                          item.plateNumber,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // CHIP KECIL INDIKATOR: Sisa BBM, Transmisi, dan Odometer
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            _buildFuelChip(item, isDark),
                                            _buildTransmissionChip(item.transmission, isDark),
                                            _buildOdometerChip(item.currentOdometer, isDark),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Aksi Bawah (Detail & Pinjam)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => VehicleDetailScreen(
                                              vehicle: item,
                                              onPinjam: widget.onSelectVehicle,
                                            ),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                                        side: BorderSide(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 9),
                                      ),
                                      child: const Text(
                                        'Detail Unit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isAvailable
                                          ? () => widget.onSelectVehicle(item)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF24487A),
                                        disabledBackgroundColor: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 9),
                                      ),
                                      child: Text(
                                        isAvailable ? 'Ajukan Pinjam' : 'Sedang Dinas',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isAvailable
                                              ? Colors.white
                                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

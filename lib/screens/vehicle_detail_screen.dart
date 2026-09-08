import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/widgets/app_image.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;
  final Function(Vehicle) onPinjam;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
    required this.onPinjam,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Widget _buildImageWidget(String path, {BoxFit fit = BoxFit.cover}) {
    return AppImage(source: path, fit: fit, placeholder: _buildPlaceholder());
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        widget.vehicle.type == VehicleType.mobil
            ? Icons.directions_car_filled
            : Icons.two_wheeler_rounded,
        size: 70,
        color: const Color(0xFF24487A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.vehicle.status == VehicleStatus.tersedia;
    final images = widget.vehicle.allImages;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
          child: SafeArea(
            bottom: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF1E293B),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Detail Kendaraan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Spesifikasi dan kelayakan fisik armada',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GALERI MULTI-FOTO DENGAN SLIDER & INDIKATOR ANGKA
            Container(
              height: 230,
              width: double.infinity,
              color: const Color(0xFFE2E8F0),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _imagePageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _buildImageWidget(images[index]);
                    },
                  ),

                  // Indikator Badge Posisi Foto (Contoh: "1 / 4")
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${_currentImageIndex + 1} / ${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. THUMBNAILS FOTO KECIL (BISA DIKLIK)
            if (images.length > 1) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final isSelected = _currentImageIndex == index;
                    return GestureDetector(
                      onTap: () {
                        _imagePageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF24487A)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _buildImageWidget(images[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // 3. INFORMASI DETAIL & SPESIFIKASI
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vehicle.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.vehicle.plateNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isAvailable ? 'Tersedia' : 'Sedang Dipakai',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isAvailable
                                ? const Color(0xFF15803D)
                                : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Spesifikasi & Keadaan Fisik',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSpecCard(
                        'Merk Unit',
                        widget.vehicle.brand,
                        Icons.directions_car_outlined,
                        const Color(0xFFEFF6FF),
                        const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 10),
                      _buildSpecCard(
                        'Warna Body',
                        widget.vehicle.color,
                        Icons.palette_outlined,
                        const Color(0xFFFDF2F8),
                        const Color(0xFFDB2777),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSpecCard(
                        'Sisa BBM',
                        widget.vehicle.fuelDisplay,
                        Icons.local_gas_station_rounded,
                        const Color(0xFFFEF3C7),
                        const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 10),
                      _buildSpecCard(
                        'Jenis BBM',
                        widget.vehicle.fuelType,
                        Icons.ev_station_rounded,
                        const Color(0xFFECFDF5),
                        const Color(0xFF059669),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSpecCard(
                        'Odometer (KM)',
                        '${widget.vehicle.currentOdometer} KM',
                        Icons.speed_rounded,
                        const Color(0xFFF1F5F9),
                        const Color(0xFF475569),
                      ),
                      const SizedBox(width: 10),
                      _buildSpecCard(
                        'Transmisi',
                        widget.vehicle.transmission,
                        Icons.tune_rounded,
                        const Color(0xFFF3E8FF),
                        const Color(0xFF7E22CE),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSpecCard(
                        'Kapasitas',
                        '${widget.vehicle.capacity} Orang',
                        Icons.groups_rounded,
                        const Color(0xFFEFF6FF),
                        const Color(0xFF1D4ED8),
                      ),
                      const SizedBox(width: 10),
                      _buildSpecCard(
                        'Kategori',
                        widget.vehicle.type == VehicleType.mobil
                            ? 'Roda 4'
                            : 'Roda 2',
                        widget.vehicle.type == VehicleType.mobil
                            ? Icons.commute_rounded
                            : Icons.two_wheeler_rounded,
                        const Color(0xFFF8FAFC),
                        const Color(0xFF334155),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Catatan Kondisi Fisik Unit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fact_check_outlined,
                            size: 18,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.vehicle.conditionNote,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isAvailable
                          ? () {
                              Navigator.pop(context);
                              widget.onPinjam(widget.vehicle);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24487A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ajukan Peminjaman Armada Ini',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecCard(
    String title,
    String value,
    IconData icon,
    Color bgIconColor,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgIconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
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
    );
  }
}

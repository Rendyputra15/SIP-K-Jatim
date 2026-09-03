import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/screens/vehicle_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Function(Vehicle) onSelectVehicle;

  const CatalogScreen({
    super.key,
    required this.vehicles,
    required this.onSelectVehicle,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _wheelFilter = 'Semua';

  Widget _buildVehicleImage(String imageUrl, VehicleType type) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _buildPlaceholderIcon(type),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, stack) => _buildPlaceholderIcon(type),
    );
  }

  Widget _buildPlaceholderIcon(VehicleType type) {
    return Center(
      child: Icon(
        type == VehicleType.mobil ? Icons.directions_car_filled : Icons.two_wheeler_rounded,
        size: 36,
        color: const Color(0xFF24487A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = widget.vehicles.where((v) {
      if (_wheelFilter == 'Roda 4' && v.type != VehicleType.mobil) return false;
      if (_wheelFilter == 'Roda 2' && v.type != VehicleType.motor) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // 1. HEADER UTAMA ABU-ABU MUDA
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          alignment: Alignment.centerLeft,
          child: const SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Katalog Armada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Pilih unit operasional dinas',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // 2. KONTEN BODY (DROPDOWN TEPAT DI BAWAH HEADER ABU)
      body: Column(
        children: [
          // Filter Dropdown Ringkas tepat di bawah header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _wheelFilter,
                      icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF24487A), size: 18),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF24487A),
                      ),
                      items: ['Semua', 'Roda 2', 'Roda 4']
                          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
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
            child: filteredList.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada kendaraan yang sesuai',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final isAvailable = item.status == VehicleStatus.tersedia;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 84,
                                      height: 74,
                                      color: const Color(0xFFEFF6FF),
                                      child: _buildVehicleImage(item.imageUrl, item.type),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.plateNumber,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              '${item.fuelDisplay} • ${item.fuelType}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF0369A1),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const Text(' • ', style: TextStyle(color: Colors.grey)),
                                            Text(
                                              '${item.currentOdometer} KM',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
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
                                        foregroundColor: const Color(0xFF24487A),
                                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Detail',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isAvailable ? () => widget.onSelectVehicle(item) : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF24487A),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Pinjam',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }
}
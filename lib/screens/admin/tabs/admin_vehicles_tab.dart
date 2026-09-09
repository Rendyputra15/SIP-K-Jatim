import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/screens/admin/dialogs/vehicle_form_dialog.dart';

class AdminVehiclesTab extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Function(Vehicle)? onAddVehicle;
  final Function(Vehicle)? onUpdateVehicle;
  final Function(String)? onDeleteVehicle;

  const AdminVehiclesTab({
    super.key,
    required this.vehicles,
    this.onAddVehicle,
    this.onUpdateVehicle,
    this.onDeleteVehicle,
  });

  @override
  State<AdminVehiclesTab> createState() => _AdminVehiclesTabState();
}

class _AdminVehiclesTabState extends State<AdminVehiclesTab> {
  String _vehicleSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.vehicles.where((v) {
          final q = _vehicleSearchQuery.toLowerCase();
          return v.name.toLowerCase().contains(q) ||
              v.plateNumber.toLowerCase().contains(q) ||
              v.brand.toLowerCase().contains(q);
        }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Katalog Armada Dinas',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kelola unit mobil, motor operasional, dan statusnya',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed:
                        () => VehicleFormDialog.show(
                          context,
                          onAddVehicle: widget.onAddVehicle,
                          onUpdateVehicle: widget.onUpdateVehicle,
                          onSuccess: () => setState(() {}),
                        ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24487A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (val) => setState(() => _vehicleSearchQuery = val),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cari mobil/motor, plat, atau merek...',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              filtered.isEmpty
                  ? const Center(child: Text('Tidak ada kendaraan yang cocok'))
                  : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final isAvailable = item.status == VehicleStatus.tersedia;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(14),
                              ),
                              child: Container(
                                width: 95,
                                height: 95,
                                color: const Color(0xFFEFF6FF),
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (c, e, s) => Center(
                                        child: Icon(
                                          item.type == VehicleType.mobil
                                              ? Icons.directions_car
                                              : Icons.two_wheeler,
                                          size: 32,
                                          color: const Color(0xFF24487A),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color:
                                              isAvailable
                                                  ? const Color(0xFFDCFCE7)
                                                  : const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          isAvailable ? 'TERSEDIA' : 'DIPAKAI',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isAvailable
                                                    ? const Color(0xFF15803D)
                                                    : const Color(0xFFB91C1C),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.plateNumber} • ${item.capacity} Kursi • ${item.transmission}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Text(
                                    'Odo: ${item.currentOdometer} KM • ${item.fuelType}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFF2563EB),
                              ),
                              onPressed:
                                  () => VehicleFormDialog.show(
                                    context,
                                    vehicleToEdit: item,
                                    onUpdateVehicle: widget.onUpdateVehicle,
                                    onSuccess: () => setState(() {}),
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Color(0xFFDC2626),
                              ),
                              onPressed: () {
                                widget.onDeleteVehicle?.call(item.id);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

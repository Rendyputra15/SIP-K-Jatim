enum VehicleType { mobil, motor }
enum VehicleStatus { tersedia, digunakan, pemeliharaan }

class Vehicle {
  final String id;
  final String name;
  final String brand;
  final String plateNumber;
  final String color;
  final VehicleType type;
  final int capacity;
  final String transmission;
  final int currentOdometer;
  final int fuelPercent;      // 0 - 100
  final String fuelType;       // Pertalite, Pertamax, Dexlite, Solar
  final String conditionNote;
  final String imageUrl;       // Gambar cover utama
  final List<String> galleryImages; // Galeri foto tambahan (bebas diubah/ditambah)
  VehicleStatus status;

  Vehicle({
    required this.id,
    required this.name,
    required this.brand,
    required this.plateNumber,
    required this.color,
    required this.type,
    required this.capacity,
    required this.transmission,
    required this.currentOdometer,
    required this.fuelPercent,
    required this.fuelType,
    required this.conditionNote,
    required this.imageUrl,
    this.galleryImages = const [],
    this.status = VehicleStatus.tersedia,
  });

  String get fuelDisplay => fuelPercent >= 100 ? 'Full (100%)' : '$fuelPercent%';

  // Menggabungkan foto utama dan foto-foto galeri
  List<String> get allImages {
    if (galleryImages.isEmpty) return [imageUrl];
    if (!galleryImages.contains(imageUrl)) {
      return [imageUrl, ...galleryImages];
    }
    return galleryImages;
  }
}
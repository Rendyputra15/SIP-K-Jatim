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
  final int fuelPercent; // 0 - 100
  final String fuelType; // Pertalite, Pertamax, Dexlite, Solar
  final String conditionNote;
  final String imageUrl; // Gambar cover utama
  final List<String>
  galleryImages; // Galeri foto tambahan (bebas diubah/ditambah)
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

  String get fuelDisplay =>
      fuelPercent >= 100 ? 'Full (100%)' : '$fuelPercent%';

  // Menjamin setiap detail kendaraan memiliki empat slot foto.
  List<String> get allImages {
    final availableImages = <String>[
      imageUrl,
      ...galleryImages.where((image) => image.isNotEmpty && image != imageUrl),
    ];

    if (availableImages.isEmpty) {
      return List<String>.filled(4, 'assets/images/logo_sipk.png');
    }

    return List<String>.generate(
      4,
      (index) => availableImages[index % availableImages.length],
    );
  }
}

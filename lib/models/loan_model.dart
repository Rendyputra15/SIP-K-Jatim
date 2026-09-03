enum LoanStatus {
  menunggu,
  pending,      // Alias untuk menunggu
  disetujui,
  approved,     // Alias untuk disetujui
  ditolak,
  rejected,     // Alias untuk ditolak
  selesai,
}

class LoanRequest {
  final String id;
  final String borrowerName;
  final String department;
  final String vehicleId;
  final String vehicleName;
  final String destination;
  final String destinationAddress;
  final DateTime startDate;
  final DateTime endDate;
  final String officialNoteNumber;
  LoanStatus status;
  final DateTime submittedAt;
  String? spkNumber;

  // Properti untuk proses pengembalian unit (BAST)
  dynamic returnOdometer; // Mendukung int maupun String
  dynamic returnFuel;     // Mendukung String ("Full", "75%") maupun int
  String? returnNotes;

  LoanRequest({
    required this.id,
    required this.borrowerName,
    required this.department,
    required this.vehicleId,
    required this.vehicleName,
    required this.destination,
    this.destinationAddress = '',
    required this.startDate,
    required this.endDate,
    this.officialNoteNumber = '-',
    this.status = LoanStatus.menunggu,
    required this.submittedAt,
    this.spkNumber,
    this.returnOdometer,
    this.returnFuel,
    this.returnNotes,
  });

  String get applicantName => borrowerName;
}
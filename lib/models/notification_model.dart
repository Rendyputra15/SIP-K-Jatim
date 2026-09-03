enum NotificationType { welcome, submitted, approved, rejected, maintenance, reminder }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;           // Format ringkas (misal: "08:30 WIB", "Kemarin", "27 Ags 2026")
  final String fullDate;       // Format lengkap (misal: "01 September 2026, 08:30 WIB")
  final String detailContent;   // Penjelasan detail untuk dialog pop-up
  final String referenceNumber; // Nomor referensi / SPK / Nota
  final NotificationType type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.fullDate,
    required this.detailContent,
    required this.referenceNumber,
    required this.type,
    this.isRead = false,
  });
}
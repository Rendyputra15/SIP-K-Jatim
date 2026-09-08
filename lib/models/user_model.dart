enum UserRole {
  superadmin, // Administrator
  admin, // Kasubag / Petugas Pool
  user, // Pegawai Pemohon
}

class AppUser {
  final String id;
  String username;
  String name;
  String nip;
  String department;
  String email;
  UserRole role;
  bool isActive;

  AppUser({
    required this.id,
    this.username = '',
    required this.name,
    required this.nip,
    required this.department,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  bool get isSuperAdmin => role == UserRole.superadmin;
  bool get isAdmin => role == UserRole.admin;
}

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

class UserProfile {
  String name;
  String nip;
  String position;
  String department;
  String email;
  String phone;
  String? profileImageUrl;

  UserProfile({
    required this.name,
    required this.nip,
    required this.position,
    required this.department,
    this.email = 'alamsyah@dinsos.jatimprov.go.id',
    this.phone = '0812-3456-7890',
    this.profileImageUrl,
  });

  UserProfile copyWith({
    String? name,
    String? nip,
    String? position,
    String? department,
    String? email,
    String? phone,
    String? profileImageUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      nip: nip ?? this.nip,
      position: position ?? this.position,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}


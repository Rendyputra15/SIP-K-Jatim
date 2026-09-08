import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/user_model.dart';

class AdminUserManagementScreen extends StatefulWidget {
  final AppUser currentUser; // Akun yang sedang login
  final List<AppUser> users;
  final Function(AppUser) onAddUser;
  final Function(AppUser) onUpdateUser;
  final Function(String) onDeleteUser;

  const AdminUserManagementScreen({
    super.key,
    required this.currentUser,
    required this.users,
    required this.onAddUser,
    required this.onUpdateUser,
    required this.onDeleteUser,
  });

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  // Filter daftar user: jika bukan superadmin, sembunyikan semua akun superadmin
  List<AppUser> get _visibleUsers {
    if (widget.currentUser.isSuperAdmin) {
      return widget.users;
    }
    // Admin biasa tidak bisa melihat akun Superadmin (Administrator)
    return widget.users.where((u) => !u.isSuperAdmin).toList();
  }

  void _showUserFormDialog({AppUser? userToEdit}) {
    final isEdit = userToEdit != null;
    final nameController = TextEditingController(text: userToEdit?.name ?? '');
    final nipController = TextEditingController(text: userToEdit?.nip ?? '');
    final deptController = TextEditingController(
      text: userToEdit?.department ?? '',
    );
    final emailController = TextEditingController(
      text: userToEdit?.email ?? '',
    );

    // Default role: jika superadmin buat akun baru -> default admin, jika admin biasa -> hanya user
    UserRole selectedRole =
        userToEdit?.role ??
        (widget.currentUser.isSuperAdmin ? UserRole.admin : UserRole.user);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit
                              ? 'Edit Akun Pengguna'
                              : 'Tambah Akun Pengguna',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 14),

                    // Input Nama
                    _buildTextField(
                      nameController,
                      'Nama Lengkap & Gelar',
                      'Contoh: Alamsyah, S.Kom',
                    ),
                    const SizedBox(height: 12),

                    // Input NIP
                    _buildTextField(
                      nipController,
                      'NIP Pegawai',
                      'Contoh: 199503152020121002',
                    ),
                    const SizedBox(height: 12),

                    // Input Bidang
                    _buildTextField(
                      deptController,
                      'Bidang / Seksi / Bagian',
                      'Contoh: Bidang Linjamsos',
                    ),
                    const SizedBox(height: 12),

                    // Input Email
                    _buildTextField(
                      emailController,
                      'Email Resmi Dinsos',
                      'nama@dinsos.jatimprov.go.id',
                    ),
                    const SizedBox(height: 12),

                    // Pemilihan Role
                    const Text(
                      'Peran Pengguna (Hak Akses)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<UserRole>(
                      initialValue: selectedRole,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      // Administrator bisa menetapkan Admin & User. Admin biasa HANYA bisa menetapkan User
                      items: [
                        if (widget.currentUser.isSuperAdmin) ...[
                          const DropdownMenuItem(
                            value: UserRole.admin,
                            child: Text(
                              'Admin (Kasubag / Aset)',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                        const DropdownMenuItem(
                          value: UserRole.user,
                          child: Text(
                            'Pegawai (User Pemohon)',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedRole = val);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (isEdit) {
                              userToEdit.name = nameController.text.trim();
                              userToEdit.nip = nipController.text.trim();
                              userToEdit.department = deptController.text
                                  .trim();
                              userToEdit.email = emailController.text.trim();
                              userToEdit.role = selectedRole;
                              widget.onUpdateUser(userToEdit);
                            } else {
                              final newUser = AppUser(
                                id: 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                                name: nameController.text.trim(),
                                nip: nipController.text.trim(),
                                department: deptController.text.trim(),
                                email: emailController.text.trim(),
                                role: selectedRole,
                              );
                              widget.onAddUser(newUser);
                            }
                            Navigator.pop(ctx);
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24487A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'Perbarui Data Akun' : 'Simpan Akun Baru',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Akun?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFFDC2626),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun ${user.name} (${user.role.name.toUpperCase()}) dari sistem?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDeleteUser(user.id);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          validator: (val) =>
              val == null || val.isEmpty ? 'Kolom ini wajib diisi' : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleList = _visibleUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.currentUser.isSuperAdmin
              ? 'Kelola Akun Admin & Pegawai'
              : 'Kelola Akun Pegawai (User)',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF24487A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserFormDialog(),
        backgroundColor: const Color(0xFF24487A),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: Text(
          widget.currentUser.isSuperAdmin
              ? 'Tambah Admin / User'
              : 'Tambah User Pegawai',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: visibleList.isEmpty
          ? const Center(child: Text('Belum ada data akun.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visibleList.length,
              itemBuilder: (ctx, i) {
                final user = visibleList[i];
                final isSuper = user.isSuperAdmin;
                final isAdminRole = user.isAdmin;

                // Proteksi Otorisasi:
                // Superadmin tidak bisa dihapus atau diedit oleh siapapun di dalam daftar kartu
                // Admin biasa hanya bisa mengedit/menghapus user biasa
                final bool canManage = widget.currentUser.isSuperAdmin
                    ? !isSuper // Superadmin tidak bisa menghapus akun superadmin sendiri dari sini
                    : !isAdminRole &&
                          !isSuper; // Admin biasa hanya bisa manage user

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSuper
                          ? const Color(0xFFF59E0B)
                          : (isAdminRole
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0)),
                      width: isSuper ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: isSuper
                            ? const Color(0xFFFEF3C7)
                            : (isAdminRole
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFF1F5F9)),
                        child: Icon(
                          isSuper
                              ? Icons.shield_rounded
                              : (isAdminRole
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.person_rounded),
                          color: isSuper
                              ? const Color(0xFFB45309)
                              : (isAdminRole
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSuper
                                        ? const Color(0xFFFEF3C7)
                                        : (isAdminRole
                                              ? const Color(0xFFDBEAFE)
                                              : const Color(0xFFF1F5F9)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isSuper
                                        ? 'SUPERADMIN'
                                        : user.role.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isSuper
                                          ? const Color(0xFFB45309)
                                          : (isAdminRole
                                                ? const Color(0xFF1E40AF)
                                                : const Color(0xFF475569)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NIP. ${user.nip}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              user.department,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (canManage) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Color(0xFF2563EB),
                          ),
                          onPressed: () =>
                              _showUserFormDialog(userToEdit: user),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Color(0xFFDC2626),
                          ),
                          onPressed: () => _showDeleteConfirmDialog(user),
                        ),
                      ] else if (isSuper) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 18,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/user_model.dart';

class UserFormDialog {
  static Widget _buildFormInput(
    TextEditingController ctrl,
    String label,
    String hint, {
    bool isNumber = false,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          obscureText: isPassword,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          validator:
              validator ??
              ((val) =>
                  val == null || val.trim().isEmpty ? 'Wajib diisi' : null),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    AppUser? userToEdit,
    required UserRole defaultRole,
    bool isSuperAdmin = false,
    Function(AppUser)? onAddUser,
    Function(AppUser)? onUpdateUser,
    VoidCallback? onSuccess,
  }) {
    final isEdit = userToEdit != null;
    final nameCtrl = TextEditingController(text: userToEdit?.name ?? '');
    final nipCtrl = TextEditingController(text: userToEdit?.nip ?? '');
    final deptCtrl = TextEditingController(text: userToEdit?.department ?? '');
    final emailCtrl = TextEditingController(text: userToEdit?.email ?? '');
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final roleLabel =
        defaultRole == UserRole.admin ? 'Admin (Kasubag)' : 'Pegawai (User)';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit $roleLabel' : 'Tambah $roleLabel',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 20),
                  _buildFormInput(
                    nameCtrl,
                    'Nama Lengkap',
                    'Ahmad Fauzi, S.ST',
                  ),
                  const SizedBox(height: 10),
                  _buildFormInput(nipCtrl, 'NIP', '198501012010011001'),
                  const SizedBox(height: 10),
                  _buildFormInput(
                    deptCtrl,
                    'Bidang Dinas',
                    'Bidang Linjamsos',
                  ),
                  const SizedBox(height: 10),
                  _buildFormInput(
                    emailCtrl,
                    'Email',
                    'nama@dinsos.jatimprov.go.id',
                  ),
                  const SizedBox(height: 10),

                  // Hanya munculkan field password jika User Baru atau jika yang mengedit adalah Superadmin
                  if (!isEdit || isSuperAdmin) ...[
                    _buildFormInput(
                      passwordCtrl,
                      isEdit
                          ? 'Ganti Password (Kosongkan jika tidak diubah)'
                          : 'Password',
                      '********',
                      isPassword: true,
                      validator: (val) {
                        if (!isEdit && (val == null || val.isEmpty)) {
                          return 'Password wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (isEdit) {
                            userToEdit.name = nameCtrl.text.trim();
                            userToEdit.nip = nipCtrl.text.trim();
                            userToEdit.department = deptCtrl.text.trim();
                            userToEdit.email = emailCtrl.text.trim();
                            onUpdateUser?.call(userToEdit);
                          } else {
                            final newUser = AppUser(
                              id: 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              name: nameCtrl.text.trim(),
                              nip: nipCtrl.text.trim(),
                              department: deptCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              role: defaultRole,
                            );
                            onAddUser?.call(newUser);
                          }
                          Navigator.pop(ctx);
                          onSuccess?.call();
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
                        isEdit ? 'Simpan' : 'Tambahkan Akun',
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
    );
  }
}

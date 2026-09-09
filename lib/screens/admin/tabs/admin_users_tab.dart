import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/screens/admin/dialogs/user_form_dialog.dart';

class AdminUsersTab extends StatefulWidget {
  final UserRole targetRole;
  final String title;
  final String subtitle;
  final List<AppUser> userList;
  final bool isSuperAdmin;
  final Function(AppUser)? onAddUser;
  final Function(AppUser)? onUpdateUser;
  final Function(String)? onDeleteUser;

  const AdminUsersTab({
    super.key,
    required this.targetRole,
    required this.title,
    required this.subtitle,
    required this.userList,
    this.isSuperAdmin = false,
    this.onAddUser,
    this.onUpdateUser,
    this.onDeleteUser,
  });

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _userSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.userList.where((u) {
          final q = _userSearchQuery.toLowerCase();
          return u.name.toLowerCase().contains(q) ||
              u.nip.contains(q) ||
              u.department.toLowerCase().contains(q);
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed:
                        () => UserFormDialog.show(
                          context,
                          defaultRole: widget.targetRole,
                          isSuperAdmin: widget.isSuperAdmin,
                          onAddUser: widget.onAddUser,
                          onUpdateUser: widget.onUpdateUser,
                          onSuccess: () => setState(() {}),
                        ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(
                      widget.targetRole == UserRole.admin
                          ? 'Tambah Admin'
                          : 'Tambah User',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.targetRole == UserRole.admin
                              ? const Color(0xFF1E40AF)
                              : const Color(0xFF24487A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (val) => setState(() => _userSearchQuery = val),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan nama, NIP, atau bidang...',
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
                  ? const Center(
                    child: Text(
                      'Tidak ada akun yang cocok',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final user = filtered[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  widget.targetRole == UserRole.admin
                                      ? const Color(0xFFDBEAFE)
                                      : const Color(0xFFF1F5F9),
                              child: Icon(
                                widget.targetRole == UserRole.admin
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.person_rounded,
                                color:
                                    widget.targetRole == UserRole.admin
                                        ? const Color(0xFF1E40AF)
                                        : const Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
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
                                    '${user.department} • ${user.email}',
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
                                  () => UserFormDialog.show(
                                    context,
                                    userToEdit: user,
                                    defaultRole: widget.targetRole,
                                    isSuperAdmin: widget.isSuperAdmin,
                                    onUpdateUser: widget.onUpdateUser,
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
                                widget.onDeleteUser?.call(user.id);
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

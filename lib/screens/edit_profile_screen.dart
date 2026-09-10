import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/services/theme_service.dart';
import 'package:simodis_jatim/widgets/app_image.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile updatedProfile)? onSave;

  const EditProfileScreen({
    super.key,
    required this.profile,
    this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _nipController;
  late final TextEditingController _positionController;
  late final TextEditingController _departmentController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  String? _profileImageUrl;
  bool _isSaving = false;

  final List<String> _positionSuggestions = [
    'Staf Pelaksana',
    'Pengadministrasi Perkantoran',
    'Analis Kebijakan',
    'Kasubag Umum & Kepegawaian',
    'Pranata Komputer',
    'Penyuluh Sosial',
    'Pekerja Sosial',
  ];

  final List<String> _departmentSuggestions = [
    'Dinas Sosial Jawa Timur',
    'Subbag Penyusunan Program & Anggaran',
    'Subbag Tata Usaha & Pengelolaan Aset',
    'Subbag Keuangan',
    'Bidang Perlindungan & Jaminan Sosial (Linjamsos)',
    'Bidang Rehabilitasi Sosial (Rehsos)',
    'Bidang Penanganan Fakir Miskin (PFM)',
    'Bidang Pemberdayaan Sosial (Dayasos)',
    'UPT Dinsos Jawa Timur',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _nipController = TextEditingController(text: widget.profile.nip);
    _positionController = TextEditingController(text: widget.profile.position);
    _departmentController = TextEditingController(text: widget.profile.department);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _profileImageUrl = widget.profile.profileImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nipController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _buildEmployeeAvatar({
    required String avatarId,
    required Color backgroundColor,
    required Color iconColor,
    double radius = 28,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Icon(
          avatarId == 'pegawai-2'
              ? Icons.support_agent_rounded
              : Icons.badge_rounded,
          color: iconColor,
          size: radius * 1.15,
        ),
      ),
    );
  }

  Widget _buildAvatarWidget() {
    if (_profileImageUrl == 'avatar:pegawai-1') {
      return _buildEmployeeAvatar(
        avatarId: 'pegawai-1',
        backgroundColor: const Color(0xFFDCEBE8),
        iconColor: const Color(0xFF5D8E86),
        radius: 46,
      );
    }
    if (_profileImageUrl == 'avatar:pegawai-2') {
      return _buildEmployeeAvatar(
        avatarId: 'pegawai-2',
        backgroundColor: const Color(0xFFE6E1F0),
        iconColor: const Color(0xFF7D719C),
        radius: 46,
      );
    }
    if (_profileImageUrl != null &&
        imageProviderFromSource(_profileImageUrl!) != null) {
      return CircleAvatar(
        radius: 46,
        backgroundColor: const Color(0xFFE2E8F0),
        backgroundImage: imageProviderFromSource(_profileImageUrl!),
      );
    }

    return const CircleAvatar(
      radius: 46,
      backgroundColor: Color(0xFFFBBF24),
      child: Icon(
        Icons.person_rounded,
        size: 52,
        color: Color(0xFF1E293B),
      ),
    );
  }

  void _showChangePhotoDialog() {
    final isDark = ThemeService.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Foto / Avatar Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Pilih avatar dinas atau unggah foto:',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _profileImageUrl = null);
                      Navigator.pop(ctx);
                    },
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFFFBBF24),
                          child: Icon(Icons.person_rounded, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Standar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _profileImageUrl = 'avatar:pegawai-1');
                      Navigator.pop(ctx);
                    },
                    child: Column(
                      children: [
                        _buildEmployeeAvatar(
                          avatarId: 'pegawai-1',
                          backgroundColor: const Color(0xFFDCEBE8),
                          iconColor: const Color(0xFF5D8E86),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pegawai 1',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _profileImageUrl = 'avatar:pegawai-2');
                      Navigator.pop(ctx);
                    },
                    child: Column(
                      children: [
                        _buildEmployeeAvatar(
                          avatarId: 'pegawai-2',
                          backgroundColor: const Color(0xFFE6E1F0),
                          iconColor: const Color(0xFF7D719C),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pegawai 2',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked == null) return;
                    if (!isSupportedImageFile(picked.name)) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pilih file gambar dengan format PNG, JPG, atau JPEG.',
                          ),
                        ),
                      );
                      return;
                    }
                    final bytes = await picked.readAsBytes();
                    if (!mounted) return;
                    setState(() {
                      _profileImageUrl = imageDataUri(picked.name, bytes);
                    });
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Unggah dari Galeri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF24487A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final updatedProfile = widget.profile.copyWith(
      name: _nameController.text.trim(),
      nip: _nipController.text.trim(),
      position: _positionController.text.trim(),
      department: _departmentController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      profileImageUrl: _profileImageUrl,
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _isSaving = false);

      widget.onSave?.call(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF16A34A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Profil berhasil diperbarui!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.pop(context, updatedProfile);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: const Text(
              'Simpan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF24487A),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 750));
          if (mounted) setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AVATAR PICKER HEADER
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF24487A).withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildAvatarWidget(),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: InkWell(
                            onTap: _showChangePhotoDialog,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _showChangePhotoDialog,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          'Ubah Foto Profil',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // SEKSI 1: INFORMASI KEPEGAWAIAN
              _buildSectionHeader(
                icon: Icons.badge_outlined,
                title: 'Informasi Kepegawaian',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAMA LENGKAP
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nama lengkap tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // NIP
                    _buildTextField(
                      controller: _nipController,
                      label: 'NIP (Nomor Induk Pegawai)',
                      hint: 'Contoh: 199503152020121002',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'NIP tidak boleh kosong';
                        }
                        if (val.trim().length < 8) {
                          return 'NIP minimal 8 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // JABATAN
                    _buildTextField(
                      controller: _positionController,
                      label: 'Jabatan Kedinasan',
                      hint: 'Contoh: Staf Pelaksana',
                      icon: Icons.work_outline_rounded,
                      isDark: isDark,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Jabatan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _positionSuggestions.map((pos) {
                        final isSelected = _positionController.text.trim() == pos;
                        return ChoiceChip(
                          label: Text(
                            pos,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF24487A),
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          onSelected: (_) {
                            setState(() {
                              _positionController.text = pos;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // BIDANG
                    _buildTextField(
                      controller: _departmentController,
                      label: 'Bidang / Unit Kerja',
                      hint: 'Contoh: Dinas Sosial Jawa Timur',
                      icon: Icons.business_outlined,
                      isDark: isDark,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Bidang tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _departmentSuggestions.map((dept) {
                        final isSelected = _departmentController.text.trim() == dept;
                        return ChoiceChip(
                          label: Text(
                            dept,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF24487A),
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          onSelected: (_) {
                            setState(() {
                              _departmentController.text = dept;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SEKSI 2: INFORMASI KONTAK & AKUN
              _buildSectionHeader(
                icon: Icons.contact_mail_outlined,
                title: 'Informasi Kontak & Akun',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    // EMAIL
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Kedinasan',
                      hint: 'nama@dinsos.jatimprov.go.id',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // NOMOR WHATSAPP / TELEPON
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Nomor WhatsApp / HP',
                      hint: 'Contoh: 0812-3456-7890',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // TOMBOL SIMPAN & BATAL
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: Text(
                        _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF24487A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

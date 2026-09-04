import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';

class AdminApprovalScreen extends StatefulWidget {
  final List<LoanRequest> requests;
  final Function(LoanRequest, bool) onVerify;
  final Function(LoanRequest, int, String, String) onReturn;
  final AppUser? currentUser;
  final List<AppUser>? users;
  final Function(AppUser)? onAddUser;
  final Function(AppUser)? onUpdateUser;
  final Function(String)? onDeleteUser;

  final List<Vehicle>? vehicles;
  final Function(Vehicle)? onAddVehicle;
  final Function(Vehicle)? onUpdateVehicle;
  final Function(String)? onDeleteVehicle;

  const AdminApprovalScreen({
    super.key,
    required this.requests,
    required this.onVerify,
    required this.onReturn,
    this.currentUser,
    this.users,
    this.onAddUser,
    this.onUpdateUser,
    this.onDeleteUser,
    this.vehicles,
    this.onAddVehicle,
    this.onUpdateVehicle,
    this.onDeleteVehicle,
  });

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  int _requestSubTabIndex = 0; // 0: Menunggu, 1: Aktif, 2: Riwayat
  String _userSearchQuery = '';
  String _vehicleSearchQuery = '';
  bool _isSidebarExpanded = true; // State untuk hide/show sidebar

  bool get _isSuperAdmin => widget.currentUser?.isSuperAdmin ?? false;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(
      length: _isSuperAdmin ? 5 : 3, // Tambah 1 untuk Dashboard (Index 0)
      vsync: this,
    );
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatDateTimeFull(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} Pukul ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} WIB';
  }

  // DIALOG DETAIL PERMOHONAN LENGKAP DENGAN TOMBOL APPROVAL ATAS-BAWAH
  void _showDetailLoanDialog(BuildContext context, LoanRequest loan) {
    final durationDays = loan.endDate.difference(loan.startDate).inDays + 1;
    final isPending =
        loan.status == LoanStatus.menunggu || loan.status == LoanStatus.pending;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Dialog
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detail Pengajuan Peminjaman',
                      style: TextStyle(
                        fontSize: 15,
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
                const SizedBox(height: 4),
                Text(
                  'ID Registrasi: ${loan.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'monospace',
                  ),
                ),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),

                // Informasi Waktu Masuk Sistem (Jam & Menit)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        size: 20,
                        color: Color(0xFF24487A),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Waktu Pengajuan Diterima:',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              _formatDateTimeFull(loan.submittedAt),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Data Pemohon & Kendaraan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 8),
                _buildPopupDetailRow('Nama Pemohon', loan.borrowerName),
                _buildPopupDetailRow(
                  'Unit Kerja / Bidang',
                  loan.department.isEmpty
                      ? 'Dinas Sosial Jatim'
                      : loan.department,
                ),
                _buildPopupDetailRow('Armada Diajukan', loan.vehicleName),
                _buildPopupDetailRow(
                  'Jadwal Tugas',
                  '${_formatDate(loan.startDate)} s/d ${_formatDate(loan.endDate)} ($durationDays Hari Kerja)',
                ),

                const SizedBox(height: 14),
                const Text(
                  'Rincian Penugasan Dinas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 8),
                _buildPopupDetailRow('Tujuan Dinas', loan.destination),
                _buildPopupDetailRow(
                  'Alamat Lengkap',
                  loan.destinationAddress.isEmpty
                      ? 'Area Kota / UPT Terkait'
                      : loan.destinationAddress,
                ),
                _buildPopupDetailRow(
                  'Deskripsi Keperluan',
                  loan.purposeDescription.isEmpty
                      ? '-'
                      : loan.purposeDescription,
                ),
                _buildPopupDetailRow(
                  'Nomor Nota Dinas',
                  loan.officialNoteNumber.isEmpty
                      ? '-'
                      : loan.officialNoteNumber,
                ),
                _buildPopupDetailRow(
                  'Surat Usulan Bidang',
                  'Terlampir & Tervalidasi E-Office',
                ),

                if (loan.spkNumber != null) ...[
                  const SizedBox(height: 8),
                  _buildPopupDetailRow(
                    'No. Terbit Nota Dinas',
                    loan.spkNumber!,
                  ),
                ],

                const SizedBox(height: 20),

                // TOMBOL ATAS-BAWAH HANYA MUNCUL JIKA STATUS MASIH MENUNGGU
                if (isPending) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showConfirmApproval(context, loan, true);
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text(
                        'Setujui & Terbitkan Nota Dinas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showConfirmApproval(context, loan, false);
                      },
                      icon: const Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: Color(0xFFDC2626),
                      ),
                      label: const Text(
                        'Tolak Permohonan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24487A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmApproval(
    BuildContext context,
    LoanRequest loan,
    bool approve,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          approve ? 'Konfirmasi Terbitkan Nota Dinas?' : 'Tolak Permohonan?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: approve ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          ),
        ),
        content: Text(
          approve
              ? 'Sistem akan otomatis mengirimkan Softfile Nota Dinas resmi ke akun pemohon ${loan.borrowerName} untuk dicetak.'
              : 'Permohonan peminjaman armada oleh ${loan.borrowerName} akan ditolak.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onVerify(loan, approve);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    approve
                        ? 'Permohonan disetujui. Softfile Nota Dinas otomatis dikirim ke akun pemohon.'
                        : 'Permohonan telah ditolak.',
                  ),
                  backgroundColor: approve
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: Text(approve ? 'Ya, Terbitkan' : 'Ya, Tolak'),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DIALOG FORM TAMBAH / EDIT KENDARAAN (OPSI 2 IMMUTABLE)
  void _showVehicleFormDialog({Vehicle? vehicleToEdit}) {
    final isEdit = vehicleToEdit != null;
    final nameCtrl = TextEditingController(text: vehicleToEdit?.name ?? '');
    final brandCtrl = TextEditingController(
      text: vehicleToEdit?.brand ?? 'Toyota',
    );
    final plateCtrl = TextEditingController(
      text: vehicleToEdit?.plateNumber ?? 'L ',
    );
    final colorCtrl = TextEditingController(
      text: vehicleToEdit?.color ?? 'Hitam',
    );
    final capacityCtrl = TextEditingController(
      text: vehicleToEdit?.capacity.toString() ?? '7',
    );
    final transCtrl = TextEditingController(
      text: vehicleToEdit?.transmission ?? 'Otomatis',
    );
    final fuelTypeCtrl = TextEditingController(
      text: vehicleToEdit?.fuelType ?? 'Pertamax / Dexlite',
    );
    final odoCtrl = TextEditingController(
      text: vehicleToEdit?.currentOdometer.toString() ?? '10000',
    );
    final imgUrlCtrl = TextEditingController(
      text:
          vehicleToEdit?.imageUrl ??
          'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800&q=80',
    );
    final noteCtrl = TextEditingController(
      text:
          vehicleToEdit?.conditionNote ??
          'Kondisi prima, siap operasional dinas luar kota.',
    );

    VehicleType selectedType = vehicleToEdit?.type ?? VehicleType.mobil;
    VehicleStatus selectedStatus =
        vehicleToEdit?.status ?? VehicleStatus.tersedia;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
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
                              ? 'Edit Armada Kendaraan'
                              : 'Tambah Armada Baru',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),

                    _buildFormInput(
                      nameCtrl,
                      'Nama Kendaraan',
                      'Toyota Innova Reborn',
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFormInput(brandCtrl, 'Merek', 'Toyota'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormInput(
                            plateCtrl,
                            'Plat Nomor',
                            'L 1023 SP',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jenis',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<VehicleType>(
                                initialValue: selectedType,
                                decoration: _inputDecoration(),
                                items: const [
                                  DropdownMenuItem(
                                    value: VehicleType.mobil,
                                    child: Text('Mobil'),
                                  ),
                                  DropdownMenuItem(
                                    value: VehicleType.motor,
                                    child: Text('Motor'),
                                  ),
                                ],
                                onChanged: (v) => setModalState(
                                  () => selectedType = v ?? VehicleType.mobil,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Unit',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<VehicleStatus>(
                                initialValue: selectedStatus,
                                decoration: _inputDecoration(),
                                items: const [
                                  DropdownMenuItem(
                                    value: VehicleStatus.tersedia,
                                    child: Text(
                                      'Tersedia',
                                      style: TextStyle(
                                        color: Color(0xFF16A34A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: VehicleStatus.digunakan,
                                    child: Text(
                                      'Dipakai',
                                      style: TextStyle(
                                        color: Color(0xFFDC2626),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (v) => setModalState(
                                  () => selectedStatus =
                                      v ?? VehicleStatus.tersedia,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFormInput(
                            capacityCtrl,
                            'Kapasitas',
                            '7',
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormInput(
                            transCtrl,
                            'Transmisi',
                            'Matic / Manual',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _buildFormInput(
                      imgUrlCtrl,
                      'URL Gambar Armada',
                      'https://...',
                    ),
                    const SizedBox(height: 10),
                    _buildFormInput(
                      noteCtrl,
                      'Catatan Kondisi Unit',
                      'Kondisi siap dinas luar kota',
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final capacity =
                                int.tryParse(capacityCtrl.text.trim()) ?? 4;
                            final odo = int.tryParse(odoCtrl.text.trim()) ?? 0;

                            if (isEdit) {
                              final updatedVehicle = Vehicle(
                                id: vehicleToEdit.id,
                                name: nameCtrl.text.trim(),
                                brand: brandCtrl.text.trim(),
                                plateNumber: plateCtrl.text.trim(),
                                color: colorCtrl.text.trim(),
                                type: selectedType,
                                status: selectedStatus,
                                capacity: capacity,
                                transmission: transCtrl.text.trim(),
                                currentOdometer: odo,
                                fuelPercent: vehicleToEdit.fuelPercent,
                                fuelType: fuelTypeCtrl.text.trim(),
                                conditionNote: noteCtrl.text.trim(),
                                imageUrl: imgUrlCtrl.text.trim(),
                                galleryImages:
                                    vehicleToEdit.galleryImages.isNotEmpty
                                    ? vehicleToEdit.galleryImages
                                    : [imgUrlCtrl.text.trim()],
                              );
                              widget.onUpdateVehicle?.call(updatedVehicle);
                            } else {
                              final newVehicle = Vehicle(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                name: nameCtrl.text.trim(),
                                brand: brandCtrl.text.trim(),
                                plateNumber: plateCtrl.text.trim(),
                                color: colorCtrl.text.trim(),
                                type: selectedType,
                                status: selectedStatus,
                                capacity: capacity,
                                transmission: transCtrl.text.trim(),
                                currentOdometer: odo,
                                fuelPercent: 100,
                                fuelType: fuelTypeCtrl.text.trim(),
                                conditionNote: noteCtrl.text.trim(),
                                imageUrl: imgUrlCtrl.text.trim(),
                                galleryImages: [imgUrlCtrl.text.trim()],
                              );
                              widget.onAddVehicle?.call(newVehicle);
                            }
                            Navigator.pop(ctx);
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24487A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambahkan Armada',
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

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }

  // DIALOG USER FORM
  void _showUserFormDialog({
    AppUser? userToEdit,
    required UserRole defaultRole,
  }) {
    final isEdit = userToEdit != null;
    final nameCtrl = TextEditingController(text: userToEdit?.name ?? '');
    final nipCtrl = TextEditingController(text: userToEdit?.nip ?? '');
    final deptCtrl = TextEditingController(text: userToEdit?.department ?? '');
    final emailCtrl = TextEditingController(text: userToEdit?.email ?? '');
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final roleLabel = defaultRole == UserRole.admin
        ? 'Admin (Kasubag)'
        : 'Pegawai (User)';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
                  _buildFormInput(deptCtrl, 'Bidang Dinas', 'Bidang Linjamsos'),
                  const SizedBox(height: 10),
                  _buildFormInput(
                    emailCtrl,
                    'Email',
                    'nama@dinsos.jatimprov.go.id',
                  ),
                  const SizedBox(height: 10),

                  // Hanya munculkan field password jika User Baru atau jika yang mengedit adalah Superadmin
                  if (!isEdit || _isSuperAdmin) ...[
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
                            // Jika superadmin mengisi password baru, update (Hanya Mockup Logic)
                            if (_isSuperAdmin && passwordCtrl.text.isNotEmpty) {
                              // userToEdit.password = passwordCtrl.text; // Jika ada field password di model
                            }
                            widget.onUpdateUser?.call(userToEdit);
                          } else {
                            final newUser = AppUser(
                              id: 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              name: nameCtrl.text.trim(),
                              nip: nipCtrl.text.trim(),
                              department: deptCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              role: defaultRole,
                            );
                            widget.onAddUser?.call(newUser);
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

  Widget _buildFormInput(
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

  // DIALOG BAST KEMBALI
  void _showReturnDialog(BuildContext context, LoanRequest loan) {
    final kmCtrl = TextEditingController();
    String selectedFuel = 'Full (100%)';
    final noteCtrl = TextEditingController(
      text: 'Kondisi fisik lengkap & bersih.',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                    const Text(
                      'Formulir BAST Pengembalian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unit: ${loan.vehicleName} • ${loan.borrowerName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Divider(height: 20),
                    _buildFormInput(
                      kmCtrl,
                      'Odometer Terakhir (KM)',
                      'Contoh: 45680',
                      isNumber: true,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Level Sisa BBM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedFuel,
                      decoration: _inputDecoration(),
                      items:
                          [
                                'Full (100%)',
                                '3/4 (75%)',
                                '1/2 (50%)',
                                '1/4 (25%)',
                                'Kritis / Habis',
                              ]
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(
                                    f,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setDialogState(
                        () => selectedFuel = v ?? selectedFuel,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFormInput(
                      noteCtrl,
                      'Catatan Kondisi Fisik',
                      'Kondisi ban, body, dan surat lengkap',
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final km = int.tryParse(kmCtrl.text.trim()) ?? 0;
                            Navigator.pop(ctx);
                            widget.onReturn(
                              loan,
                              km,
                              selectedFuel,
                              noteCtrl.text.trim(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24487A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Simpan BAST & Kembalikan Armada',
                          style: TextStyle(fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final pendingCount = widget.requests
        .where(
          (r) =>
              r.status == LoanStatus.menunggu || r.status == LoanStatus.pending,
        )
        .length;
    final activeCount = widget.requests
        .where(
          (r) =>
              r.status == LoanStatus.disetujui ||
              r.status == LoanStatus.approved,
        )
        .length;
    final completedCount = widget.requests
        .where(
          (r) =>
              r.status == LoanStatus.selesai ||
              r.status == LoanStatus.ditolak ||
              r.status == LoanStatus.rejected,
        )
        .length;

    final allVehicles = widget.vehicles ?? [];
    final allUsers = widget.users ?? [];
    final adminList = allUsers.where((u) => u.isAdmin).toList();
    final userList = allUsers
        .where((u) => !u.isSuperAdmin && !u.isAdmin)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isMobile ? Drawer(child: _buildMobileDrawer()) : null,
      body: Row(
        children: [
          // 1. SIDEBAR (VERTICAL NAVIGATION) - ANIMATED
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isSidebarExpanded ? 200 : 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isSuperAdmin
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF24487A), const Color(0xFF1E3A8A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Header Sidebar: Ikon & Tombol Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: _isSidebarExpanded
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.center,
                        children: [
                          if (_isSidebarExpanded)
                            const Text(
                              'SIP-K DINSOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          GestureDetector(
                            onTap: () => setState(
                              () => _isSidebarExpanded = !_isSidebarExpanded,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _isSidebarExpanded
                                    ? Icons.menu_open_rounded
                                    : Icons.menu_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Menu Items
                    _buildSidebarItem(0, Icons.grid_view_rounded, 'Dashboard'),
                    _buildSidebarItem(
                      1,
                      Icons.description_rounded,
                      'Berkas Loan',
                    ),
                    if (_isSuperAdmin)
                      _buildSidebarItem(
                        2,
                        Icons.directions_car_rounded,
                        'Katalog Armada',
                      ),
                    if (_isSuperAdmin)
                      _buildSidebarItem(
                        3,
                        Icons.manage_accounts_rounded,
                        'Kelola Admin',
                      ),
                    _buildSidebarItem(
                      _isSuperAdmin ? 4 : 2,
                      Icons.people_alt_rounded,
                      'Daftar Pegawai',
                    ),

                    const Spacer(),
                    // User Profile Mini
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: _isSidebarExpanded ? 12 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: _isSuperAdmin
                                ? const Color(0xFFFBBF24)
                                : Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: _isSuperAdmin
                                  ? Colors.black
                                  : const Color(0xFF24487A),
                            ),
                          ),
                          if (_isSidebarExpanded) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.currentUser?.name.split(' ')[0] ??
                                        'Admin',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _isSuperAdmin ? 'Superadmin' : 'Kasubag',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // Header Banner
                Container(
                  padding: EdgeInsets.fromLTRB(isMobile ? 8 : 20, 16, 20, 16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      if (isMobile)
                        Builder(
                          builder: (context) => IconButton(
                            tooltip: 'Buka menu',
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: const Icon(Icons.menu_rounded),
                            color: const Color(0xFF24487A),
                          ),
                        )
                      else if (!_isSidebarExpanded) ...[
                        const Text(
                          'SIP-K',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF24487A),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(
                          height: 24,
                          child: VerticalDivider(
                            width: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isSuperAdmin
                                  ? 'SISTEM INFORMASI KENDARAAN (SUPER)'
                                  : 'MANAJEMEN ARMADA DINSOS',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'UPT Dinas Sosial Provinsi Jawa Timur',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF64748B),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Content Switcher
                Expanded(
                  child: TabBarView(
                    controller: _mainTabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildDashboardView(
                        pendingCount,
                        activeCount,
                        completedCount,
                        allVehicles.length,
                      ),
                      _buildArmadaSection(),
                      if (_isSuperAdmin)
                        _buildVehicleManagementView(allVehicles),
                      if (_isSuperAdmin)
                        _buildUserManagementView(
                          targetRole: UserRole.admin,
                          title: 'Daftar Admin (Kasubag & Tim Aset)',
                          subtitle: 'Akun pengelola verifikasi armada.',
                          userList: adminList,
                        ),
                      _buildUserManagementView(
                        targetRole: UserRole.user,
                        title: 'Daftar Pegawai (User Pemohon)',
                        subtitle: 'Akun pegawai yang berhak mengajukan.',
                        userList: userList,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView(
    int pending,
    int active,
    int completed,
    int totalVehicles,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Operasional',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          // Row 1: Status Pengajuan
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _buildModernStatCard(
                  'Antrean Masuk',
                  pending.toString(),
                  'Butuh Verifikasi',
                  Icons.hourglass_empty_rounded,
                  const Color(0xFFF59E0B),
                ),
                _buildModernStatCard(
                  'Armada Jalan',
                  active.toString(),
                  'Sedang Bertugas',
                  Icons.local_shipping_rounded,
                  const Color(0xFF10B981),
                ),
              ];
              return constraints.maxWidth < 560
                  ? Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 12),
                        cards[1],
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 16),
                        Expanded(child: cards[1]),
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),

          // Row 2: Riwayat & Total
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _buildModernStatCard(
                  'BAST Selesai',
                  completed.toString(),
                  'Total Riwayat',
                  Icons.assignment_turned_in_rounded,
                  const Color(0xFF3B82F6),
                ),
                _buildModernStatCard(
                  'Total Armada',
                  totalVehicles.toString(),
                  'Unit Terdaftar',
                  Icons.directions_car_rounded,
                  const Color(0xFF6366F1),
                ),
              ];
              return constraints.maxWidth < 560
                  ? Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 12),
                        cards[1],
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 16),
                        Expanded(child: cards[1]),
                      ],
                    );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Log Aktivitas Terakhir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),

          // Mock Log Aktivitas agar dashboard menarik
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildLogItem(
                  'Persetujuan Peminjaman',
                  'Admin menyetujui Toyota Innova (L 1023 SP)',
                  '10 Menit lalu',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                const Divider(height: 24),
                _buildLogItem(
                  'BAST Masuk',
                  'Pengembalian Unit Mitsubishi Pajero (L 4444 AS)',
                  '1 Jam lalu',
                  Icons.assignment_returned_outlined,
                  Colors.blue,
                ),
                const Divider(height: 24),
                _buildLogItem(
                  'User Baru',
                  'Penambahan Akun Pegawai: Rendy Cahyono',
                  '3 Jam lalu',
                  Icons.person_add_outlined,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(
    String title,
    String desc,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildMobileDrawer() {
    final items = <(int, IconData, String)>[
      (0, Icons.grid_view_rounded, 'Dashboard'),
      (1, Icons.description_rounded, 'Berkas Loan'),
      if (_isSuperAdmin) (2, Icons.directions_car_rounded, 'Katalog Armada'),
      if (_isSuperAdmin) (3, Icons.manage_accounts_rounded, 'Kelola Admin'),
      (_isSuperAdmin ? 4 : 2, Icons.people_alt_rounded, 'Daftar Pegawai'),
    ];

    return SafeArea(
      child: Container(
        color: _isSuperAdmin
            ? const Color(0xFF0F172A)
            : const Color(0xFF1E3A8A),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 12, 24),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'SIP-K DINSOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup menu',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
            const SizedBox(height: 12),
            for (final item in items)
              _buildMobileDrawerItem(item.$1, item.$2, item.$3),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _isSuperAdmin
                        ? const Color(0xFFFBBF24)
                        : Colors.white,
                    child: Icon(
                      Icons.person,
                      color: _isSuperAdmin
                          ? Colors.black
                          : const Color(0xFF24487A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.currentUser?.name ?? 'Administrator',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawerItem(int index, IconData icon, String label) {
    final isSelected = _mainTabController.index == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.white.withValues(alpha: 0.12),
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFFFBBF24) : Colors.white70,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: () {
        _mainTabController.animateTo(index);
        Navigator.pop(context);
        setState(() {});
      },
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    final isSelected = _mainTabController.index == index;
    return InkWell(
      onTap: () {
        setState(() {
          _mainTabController.animateTo(index);
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: _isSidebarExpanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (_isSuperAdmin ? const Color(0xFFFBBF24) : Colors.white)
                  : Colors.white.withValues(alpha: 0.4),
              size: 20,
            ),
            if (_isSidebarExpanded) ...[
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // VIEW TAB: KELOLA KATALOG
  Widget _buildVehicleManagementView(List<Vehicle> vehicleList) {
    final filtered = vehicleList.where((v) {
      final q = _vehicleSearchQuery.toLowerCase();
      return v.name.toLowerCase().contains(q) ||
          v.plateNumber.toLowerCase().contains(q) ||
          v.brand.toLowerCase().contains(q);
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. DIBUNGKUS EXPANDED AGAR TIDAK OVERFLOW
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Katalog Armada Dinas',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kelola unit mobil, motor operasional, dan statusnya',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 2. TOMBOL DIBUAT RINGKAS
                  ElevatedButton.icon(
                    onPressed: () => _showVehicleFormDialog(),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24487A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (val) => setState(() => _vehicleSearchQuery = val),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cari mobil/motor, plat, atau merek...',
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
          child: filtered.isEmpty
              ? const Center(child: Text('Tidak ada kendaraan yang cocok'))
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final item = filtered[i];
                    final isAvailable = item.status == VehicleStatus.tersedia;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(14),
                            ),
                            child: Container(
                              width: 95,
                              height: 95,
                              color: const Color(0xFFEFF6FF),
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Center(
                                  child: Icon(
                                    item.type == VehicleType.mobil
                                        ? Icons.directions_car
                                        : Icons.two_wheeler,
                                    size: 32,
                                    color: const Color(0xFF24487A),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: isAvailable
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isAvailable ? 'TERSEDIA' : 'DIPAKAI',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isAvailable
                                              ? const Color(0xFF15803D)
                                              : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.plateNumber} • ${item.capacity} Kursi • ${item.transmission}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Text(
                                  'Odo: ${item.currentOdometer} KM • ${item.fuelType}',
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
                            onPressed: () =>
                                _showVehicleFormDialog(vehicleToEdit: item),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Color(0xFFDC2626),
                            ),
                            onPressed: () {
                              widget.onDeleteVehicle?.call(item.id);
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

  // SUB-VIEW TAB 1: ARMADA & WORKFLOW
  Widget _buildArmadaSection() {
    final pending = widget.requests
        .where(
          (r) =>
              r.status == LoanStatus.menunggu || r.status == LoanStatus.pending,
        )
        .toList();
    final active = widget.requests
        .where(
          (r) =>
              r.status == LoanStatus.disetujui ||
              r.status == LoanStatus.approved,
        )
        .toList();
    final history = widget.requests
        .where(
          (r) =>
              r.status == LoanStatus.selesai ||
              r.status == LoanStatus.ditolak ||
              r.status == LoanStatus.rejected,
        )
        .toList();

    List<LoanRequest> currentList;
    if (_requestSubTabIndex == 0) {
      currentList = pending;
    } else if (_requestSubTabIndex == 1) {
      currentList = active;
    } else {
      currentList = history;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              _buildFilterChip(
                0,
                'Menunggu (${pending.length})',
                pending.isNotEmpty,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(1, 'Sedang Dinas (${active.length})', false),
              const SizedBox(width: 8),
              _buildFilterChip(2, 'Riwayat BAST', false),
            ],
          ),
        ),
        Expanded(
          child: currentList.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada permohonan pada status ini',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: currentList.length,
                  itemBuilder: (ctx, i) => _buildLoanCard(currentList[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(int index, String label, bool hasBadge) {
    final isSelected = _requestSubTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _requestSubTabIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF24487A)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // SUB-VIEW KELOLA PENGGUNA TERPISAH
  Widget _buildUserManagementView({
    required UserRole targetRole,
    required String title,
    required String subtitle,
    required List<AppUser> userList,
  }) {
    final filtered = userList.where((u) {
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
                  // BUNGKUS DENGAN EXPANDED AGAR TIDAK NABRAK KE KANAN
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
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
                  // Tombol Tambah yang ringkas
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showUserFormDialog(defaultRole: targetRole),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(
                      targetRole == UserRole.admin
                          ? 'Tambah Admin'
                          : 'Tambah User',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: targetRole == UserRole.admin
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
          child: filtered.isEmpty
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
                            backgroundColor: targetRole == UserRole.admin
                                ? const Color(0xFFDBEAFE)
                                : const Color(0xFFF1F5F9),
                            child: Icon(
                              targetRole == UserRole.admin
                                  ? Icons.admin_panel_settings_rounded
                                  : Icons.person_rounded,
                              color: targetRole == UserRole.admin
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
                            onPressed: () => _showUserFormDialog(
                              userToEdit: user,
                              defaultRole: targetRole,
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

  // KARTU PENGAJUAN: TOMBOL TOLAK & SETUJUI DIHAPUS, DIGANTI TOMBOL "LIHAT DETAIL PENGAJUAN" DI SUDUT KIRI BAWAH
  Widget _buildLoanCard(LoanRequest item) {
    Color badgeBg;
    Color badgeText;
    String statusTitle;

    switch (item.status) {
      case LoanStatus.disetujui:
      case LoanStatus.approved:
        badgeBg = const Color(0xFFDCFCE7);
        badgeText = const Color(0xFF15803D);
        statusTitle = 'DISETUJUI (NOTA DINAS TERBIT)';
        break;
      case LoanStatus.ditolak:
      case LoanStatus.rejected:
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFFB91C1C);
        statusTitle = 'DITOLAK';
        break;
      case LoanStatus.selesai:
        badgeBg = const Color(0xFFEFF6FF);
        badgeText = const Color(0xFF1D4ED8);
        statusTitle = 'SELESAI (BAST TUNTAS)';
        break;
      default:
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFFB45309);
        statusTitle = 'MENUNGGU VERIFIKASI';
    }

    final isPending =
        item.status == LoanStatus.menunggu || item.status == LoanStatus.pending;
    final isActive =
        item.status == LoanStatus.disetujui ||
        item.status == LoanStatus.approved;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.vehicleName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusTitle,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pemohon: ${item.borrowerName} • ${item.department}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                _buildInfoLine(
                  Icons.calendar_month_rounded,
                  'Jadwal',
                  '${_formatDate(item.startDate)} s/d ${_formatDate(item.endDate)}',
                ),
                const SizedBox(height: 4),
                _buildInfoLine(
                  Icons.near_me_rounded,
                  'Tujuan',
                  item.destination,
                ),
                const SizedBox(height: 4),
                _buildInfoLine(
                  Icons.description_outlined,
                  'Nota Dinas',
                  item.officialNoteNumber.isEmpty
                      ? '-'
                      : item.officialNoteNumber,
                ),
                if (item.spkNumber != null) ...[
                  const SizedBox(height: 4),
                  _buildInfoLine(
                    Icons.badge_outlined,
                    'No. Register',
                    item.spkNumber!,
                  ),
                ],
              ],
            ),
          ),

          // FOOTER KARTU MENUNGGU VERIFIKASI: HANYA ADA TOMBOL "LIHAT DETAIL" DI KIRI BAWAH
          if (isPending) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () => _showDetailLoanDialog(context, item),
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text(
                    'Lihat Detail Pengajuan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24487A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],

          // FOOTER KARTU AKTIF: PROSES BAST
          if (isActive) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showReturnDialog(context, item),
                  icon: const Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Terima Unit & Proses BAST',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24487A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoLine(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

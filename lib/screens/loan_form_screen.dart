import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/widgets/app_image.dart';

class LoanFormScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Vehicle? preselectedVehicle;
  final Function(LoanRequest) onSubmit;

  const LoanFormScreen({
    super.key,
    required this.vehicles,
    this.preselectedVehicle,
    required this.onSubmit,
  });

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  DateTimeRange? _selectedDateRange;
  Vehicle? _selectedVehicle;
  String? _selectedDepartment;
  XFile? _simPhoto;
  Uint8List? _simPhotoBytes;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.preselectedVehicle;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _addressController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  // Cek apakah step 1-3 sudah terisi untuk membuka pemilihan kendaraan
  bool get _isStepDetailsComplete {
    return _nameController.text.trim().isNotEmpty &&
        _selectedDepartment != null &&
        _selectedDateRange != null &&
        _destinationController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _purposeController.text.trim().isNotEmpty;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    // Minimal H+1 peminjaman
    final firstAllowedDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    // Batas kalender terbuka 7 hari ke depan
    final lastAllowedDate = firstAllowedDate.add(const Duration(days: 7));

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate,
      initialDateRange:
          _selectedDateRange ??
          DateTimeRange(start: firstAllowedDate, end: firstAllowedDate),
      helpText: 'PILIH RENTANG TANGGAL',
      saveText: 'PILIH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF24487A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF24487A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _pickSimPhoto(ImageSource source) async {
    final pickedPhoto = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (pickedPhoto == null) return;

    if (!isSupportedImageFile(pickedPhoto.name)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih file dengan format PNG, JPG, atau JPEG.'),
          ),
        );
      }
      return;
    }

    final bytes = await pickedPhoto.readAsBytes();
    if (!mounted) return;

    setState(() {
      _simPhoto = pickedPhoto;
      _simPhotoBytes = bytes;
    });
  }

  Future<void> _showSimPhotoPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickSimPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil foto dengan kamera'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickSimPhoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tentukan tanggal peminjaman terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih salah satu armada yang tersedia.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_simPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan upload atau foto SIM terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newLoan = LoanRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      borrowerName: _nameController.text.trim(),
      department: _selectedDepartment!,
      vehicleId: _selectedVehicle!.id,
      vehicleName: _selectedVehicle!.name,
      destination: _destinationController.text.trim(),
      destinationAddress: _addressController.text.trim(),
      purposeDescription: _purposeController.text.trim(),
      startDate: _selectedDateRange!.start,
      endDate: _selectedDateRange!.end,
      officialNoteNumber: 'Diproses saat SPK',
      simPhotoPath: _simPhoto!.path,
      status: LoanStatus.menunggu,
      submittedAt: DateTime.now(),
    );

    Navigator.pop(context); // Kembali dari form
    widget.onSubmit(newLoan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // HEADER DENGAN TEMA ABU MUDA
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
          alignment: Alignment.centerLeft,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF1E293B),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Formulir Permohonan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pengajuan pinjam kendaraan dinas',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. DATA IDENTITAS PEGAWAI
              _buildSectionTitle(
                '1. Identitas Pemohon',
                Icons.person_pin_rounded,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardBoxDecoration(),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nama Lengkap Pegawai',
                      hint: 'Masukkan nama pegawai peminjam',
                      icon: Icons.person_outline_rounded,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Nama wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _buildDepartmentDropdown(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildSectionTitle('2. Foto SIM Pengemudi', Icons.badge_rounded),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardBoxDecoration(),
                child: _simPhotoBytes == null
                    ? InkWell(
                        onTap: _showSimPhotoPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
                              width: 1.2,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 30,
                                color: Color(0xFF24487A),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Upload atau foto SIM',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF24487A),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Pastikan foto jelas dan SIM masih berlaku',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              _simPhotoBytes!,
                              width: double.infinity,
                              height: 170,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: Color(0xFF16A34A),
                              ),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Foto SIM sudah terlampir',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _showSimPhotoPicker,
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Ganti'),
                              ),
                              IconButton(
                                tooltip: 'Hapus foto SIM',
                                onPressed: () => setState(() {
                                  _simPhoto = null;
                                  _simPhotoBytes = null;
                                }),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              // 3. TANGGAL PEMINJAMAN (H+1 SAMPAI H+7)
              _buildSectionTitle(
                '3. Jadwal Peminjaman',
                Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardBoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Rentang Tanggal (Min. H+1 s/d H+7)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateBox(
                            label: 'MULAI',
                            date: _selectedDateRange?.start,
                            onTap: _pickDateRange,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        Expanded(
                          child: _buildDateBox(
                            label: 'SELESAI',
                            date: _selectedDateRange?.end,
                            onTap: _pickDateRange,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedDateRange != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: Color(0xFF24487A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Durasi Peminjaman: ${_selectedDateRange!.duration.inDays + 1} Hari',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF24487A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. TUJUAN & ALAMAT KEDINASAN
              _buildSectionTitle(
                '4. Destinasi Penugasan',
                Icons.location_on_rounded,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardBoxDecoration(),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _destinationController,
                      label: 'Tujuan Kedinasan',
                      hint: 'Contoh: Kantor UPT Dinsos Madiun / Rapat Bakorwil',
                      icon: Icons.domain_rounded,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Tujuan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Alamat Tujuan Lengkap',
                      hint: 'Masukkan alamat lokasi dinas yang dituju',
                      icon: Icons.map_outlined,
                      maxLines: 2,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Alamat tujuan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _purposeController,
                      label: 'Deskripsi Keperluan',
                      hint:
                          'Jelaskan tujuan dan kegiatan dinas yang akan dilakukan',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Deskripsi keperluan wajib diisi'
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 5. PILIH KENDARAAN (TERBUKA SETELAH DATA 1-4 LENGKAP)
              _buildSectionTitle(
                '5. Unit Armada yang Dipinjam',
                Icons.directions_car_rounded,
              ),
              const SizedBox(height: 10),
              if (!_isStepDetailsComplete)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lock_clock_rounded,
                        color: Color(0xFF64748B),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Lengkapi identitas, jadwal tanggal, dan tujuan di atas terlebih dahulu untuk melihat daftar kendaraan yang tersedia.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: widget.vehicles.map((v) {
                    final isSelected = _selectedVehicle?.id == v.id;
                    final isReady = v.status == VehicleStatus.tersedia;

                    return GestureDetector(
                      onTap: isReady
                          ? () {
                              setState(() {
                                _selectedVehicle = v;
                              });
                            }
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEFF6FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF24487A)
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.8 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 68,
                                height: 56,
                                color: const Color(0xFFF1F5F9),
                                child: AppImage(
                                  source: v.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: Icon(
                                    v.type == VehicleType.mobil
                                        ? Icons.directions_car
                                        : Icons.two_wheeler,
                                    color: const Color(0xFF24487A),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    v.plateNumber,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${v.fuelDisplay} • ${v.capacity} Penumpang',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF0369A1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isReady)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Terpakai',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected
                                    ? const Color(0xFF24487A)
                                    : const Color(0xFF94A3B8),
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isStepDetailsComplete && _selectedVehicle != null
                  ? _handleSubmit
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24487A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kirim Pengajuan Permohonan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateBox({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Color(0xFF24487A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? _formatDate(date) : 'Pilih...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: date != null
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    const departments = [
      'Sekretariat',
      'Rehabilitasi',
      'Pemberdayaan Sosial',
      'Pelaksana Teknis',
      'Penanganan Bencana',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bidang / Seksi / Sub Bagian',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedDepartment,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF24487A),
          ),
          decoration: InputDecoration(
            hintText: 'Pilih bidang pemohon',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(
              Icons.business_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
          ),
          items: departments
              .map(
                (department) => DropdownMenuItem<String>(
                  value: department,
                  child: Text(
                    department,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedDepartment = value);
          },
          validator: (value) => value == null || value.isEmpty
              ? 'Bidang pemohon wajib dipilih'
              : null,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF24487A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
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
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

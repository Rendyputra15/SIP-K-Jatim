import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/notification_model.dart';
import 'package:simodis_jatim/screens/user_dashboard_screen.dart';
import 'package:simodis_jatim/screens/catalog_screen.dart';
import 'package:simodis_jatim/screens/loan_flow_screen.dart';
import 'package:simodis_jatim/screens/notification_screen.dart';
import 'package:simodis_jatim/screens/admin_approval_screen.dart';
import 'package:simodis_jatim/screens/loan_history_screen.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/screens/login_screen.dart';
import 'package:simodis_jatim/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  final bool showLoading;

  const HomeScreen({super.key, this.role = 'user', this.showLoading = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingDashboard = true;
  int _currentIndex = 0;
  Vehicle? _selectedUnitForForm;

  UserProfile _currentUserProfile = UserProfile(
    name: 'Alamsyah',
    nip: '199503152020121002',
    position: 'Staf Pelaksana',
    department: 'Dinas Sosial Jawa Timur',
    email: 'alamsyah@dinsos.jatimprov.go.id',
    phone: '0812-3456-7890',
  );

  @override
  void initState() {
    super.initState();
    if (widget.showLoading) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() => _isLoadingDashboard = false);
        }
      });
    } else {
      _isLoadingDashboard = false;
    }
  }

  final List<Vehicle> _vehicles = [
    Vehicle(
      id: '1',
      name: 'Toyota Innova Reborn 2.4 G',
      brand: 'Toyota',
      plateNumber: 'L 1023 SP',
      color: 'Hitam Metalik',
      type: VehicleType.mobil,
      capacity: 7,
      transmission: 'Otomatis',
      currentOdometer: 45200,
      fuelPercent: 100,
      fuelType: 'Dexlite / Solar',
      conditionNote:
          'AC dingin double blower, toolkit lengkap, ban tebal, siap operasional dinas luar kota.',
      imageUrl: 'assets/images/logo_sipk.png',
      galleryImages: ['assets/images/logo_sipk.png'],
    ),
    Vehicle(
      id: '2',
      name: 'Toyota Avanza 1.3 Veloz',
      brand: 'Toyota',
      plateNumber: 'L 1455 EP',
      color: 'Silver',
      type: VehicleType.mobil,
      capacity: 7,
      transmission: 'Manual',
      currentOdometer: 62100,
      fuelPercent: 75,
      fuelType: 'Pertalite / Pertamax',
      conditionNote:
          'Kondisi mesin terawat, body mulus, rem baru diservis, kelengkapan surat lengkap.',
      imageUrl: 'assets/images/logo_sipk.png',
      galleryImages: ['assets/images/logo_sipk.png'],
    ),
    Vehicle(
      id: '3',
      name: 'Isuzu Elf Minibus Dinsos Jatim',
      brand: 'Isuzu',
      plateNumber: 'L 7002 AP',
      color: 'Putih Kombinasi Biru',
      type: VehicleType.mobil,
      capacity: 16,
      transmission: 'Manual',
      currentOdometer: 89400,
      fuelPercent: 50,
      fuelType: 'Solar Subsidi / Dexlite',
      conditionNote:
          'Khusus penugasan rombongan satgas linjamsos & dropping logistik sosial.',
      imageUrl: 'assets/images/logo_sipk.png',
      galleryImages: ['assets/images/logo_sipk.png'],
    ),
    Vehicle(
      id: '4',
      name: 'Honda Vario 160 CBS',
      brand: 'Honda',
      plateNumber: 'L 3341 DS',
      color: 'Hitam Doff',
      type: VehicleType.motor,
      capacity: 2,
      transmission: 'Matic',
      currentOdometer: 14200,
      fuelPercent: 100,
      fuelType: 'Pertamax',
      conditionNote:
          'Unit responsif dan lincah, khusus kurir dokumen dan dinas dalam kota Surabaya.',
      imageUrl: 'assets/images/logo_sipk.png',
      galleryImages: ['assets/images/logo_sipk.png'],
    ),
    Vehicle(
      id: '5',
      name: 'Yamaha NMAX 155 ABS',
      brand: 'Yamaha',
      plateNumber: 'L 4910 OS',
      color: 'Abu-Abu Doff',
      type: VehicleType.motor,
      capacity: 2,
      transmission: 'Matic',
      currentOdometer: 19800,
      fuelPercent: 80,
      fuelType: 'Pertamax',
      conditionNote:
          'Kondisi ban depan belakang baru, rem ABS responsif, bagasi lega untuk jas hujan dan helm.',
      imageUrl: 'assets/images/logo_sipk.png',
      galleryImages: ['assets/images/logo_sipk.png'],
    ),
    Vehicle(
      id: '6',
      name: 'Honda Supra X 125 Helm-in',
      brand: 'Honda',
      plateNumber: 'L 2890 PS',
      color: 'Hitam Merah',
      type: VehicleType.motor,
      capacity: 2,
      transmission: 'Manual (Bebek)',
      currentOdometer: 38700,
      fuelPercent: 45,
      fuelType: 'Pertalite',
      conditionNote:
          'Sangat irit bahan bakar, cocok untuk tugas operasional kurir surat dinas harian.',
      imageUrl: 'assets/images/logo_sipk.png',
      galleryImages: ['assets/images/logo_sipk.png'],
    ),
  ];

  final List<LoanRequest> _loans = [
    // 1. DATA MENUNGGU VERIFIKASI (Masuk Tab 1: Verifikasi Kasubag)
    LoanRequest(
      id: 'REQ-2026-0902-001',
      borrowerName: 'Rendy Cahyono Putra',
      department: 'Subbag Penyusunan Program & Anggaran',
      vehicleId: '1',
      vehicleName: 'Toyota Innova Reborn 2.4 G',
      destination: 'Bakorwil III Malang & UPT Dinsos Lawang',
      destinationAddress: 'Jl. Raya Singosari No. 120, Malang',
      startDate: DateTime(2026, 9, 3),
      endDate: DateTime(2026, 9, 5),
      officialNoteNumber: '005/1422/107.4.1/2026',
      status: LoanStatus.menunggu,
      submittedAt: DateTime(2026, 9, 2, 8, 30),
    ),
    LoanRequest(
      id: 'REQ-2026-0902-002',
      borrowerName: 'Dewi Sekar Arum, S.Sos',
      department: 'Bidang Penanganan Fakir Miskin (PFM)',
      vehicleId: '4',
      vehicleName: 'Honda Vario 160 CBS',
      destination: 'Bappeda Provinsi Jawa Timur',
      destinationAddress: 'Jl. Pahlawan No. 110, Surabaya',
      startDate: DateTime(2026, 9, 3),
      endDate: DateTime(2026, 9, 3),
      officialNoteNumber: '005/1429/107.2.2/2026',
      status: LoanStatus.menunggu,
      submittedAt: DateTime(2026, 9, 2, 9, 15),
    ),

    // 2. DATA SUDAH DISETUJUI & SEDANG BERDINAS (Masuk Tab 2: Aktif / BAST)
    LoanRequest(
      id: 'REQ-2026-0831-010',
      borrowerName: 'Bambang Triyono, S.ST',
      department: 'Bidang Perlindungan & Jaminan Sosial (Linjamsos)',
      vehicleId: '3',
      vehicleName: 'Isuzu Elf Minibus Dinsos Jatim',
      destination: 'Penyaluran Bantuan Satgas Tagana Kab. Bojonegoro',
      destinationAddress: 'Kompleks Pemkab & Gudang Logistik Dinsos Bojonegoro',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 4),
      officialNoteNumber: '005/1398/107.3/2026',
      status: LoanStatus.disetujui,
      submittedAt: DateTime(2026, 8, 31, 10, 0),
      spkNumber: 'ND-5512/DINSOS/2026',
    ),
    LoanRequest(
      id: 'REQ-2026-0901-008',
      borrowerName: 'Nurul Hidayati, M.Si',
      department: 'Bidang Rehabilitasi Sosial (Rehsos)',
      vehicleId: '2',
      vehicleName: 'Toyota Avanza 1.3 Veloz',
      destination: 'Monev UPT PRSPA Magetan & Ponorogo',
      destinationAddress: 'Jl. Pahlawan No. 45, Magetan',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 3),
      officialNoteNumber: '005/1405/107.1/2026',
      status: LoanStatus.disetujui,
      submittedAt: DateTime(2026, 9, 1, 7, 45),
      spkNumber: 'ND-5519/DINSOS/2026',
    ),

    // 3. DATA SELESAI / PENGEMBALIAN BAST (Masuk Tab 3: Riwayat Selesai)
    LoanRequest(
      id: 'REQ-2026-0828-004',
      borrowerName: 'Agus Setiawan, A.Md',
      department: 'Subbag Keuangan & Aset',
      vehicleId: '1',
      vehicleName: 'Toyota Innova Reborn 2.4 G',
      destination: 'Badan Pengelola Keuangan dan Aset Daerah (BPKAD) Jatim',
      destinationAddress: 'Jl. Johar No. 17, Surabaya',
      startDate: DateTime(2026, 8, 28),
      endDate: DateTime(2026, 8, 29),
      officialNoteNumber: '005/1350/107.4.2/2026',
      status: LoanStatus.selesai,
      submittedAt: DateTime(2026, 8, 27, 14, 20),
      spkNumber: 'ND-5490/DINSOS/2026',
      returnOdometer: 45200,
      returnFuel: 'Full (100%)',
      returnNotes:
          'Kondisi kendaraan bersih, toolkit lengkap, tidak ada kendala mesin.',
    ),
    LoanRequest(
      id: 'REQ-2026-0825-002',
      borrowerName: 'Irfan Maulana, S.Kom',
      department: 'Seksi Data & Informasi Kesejahteraan Sosial',
      vehicleId: '5',
      vehicleName: 'Yamaha NMAX 155 ABS',
      destination: 'Diskominfo Pemprov Jawa Timur',
      destinationAddress: 'Jl. A. Yani No. 242-244, Surabaya',
      startDate: DateTime(2026, 8, 25),
      endDate: DateTime(2026, 8, 25),
      officialNoteNumber: '005/1310/107.5/2026',
      status: LoanStatus.selesai,
      submittedAt: DateTime(2026, 8, 24, 11, 0),
      spkNumber: 'ND-5472/DINSOS/2026',
      returnOdometer: 19800,
      returnFuel: '3/4 (75%)',
      returnNotes: 'Lengkap dengan jas hujan dinas dan 2 buah helm.',
    ),
  ];

  final List<AppUser> _appUsers = [
    AppUser(
      id: 'ROOT-001',
      username: 'superadmin',
      name: 'Administrator Pusat',
      nip: '19700101 199003 1 001',
      department: 'Dinas Sosial Provinsi Jawa Timur',
      email: 'administrator@dinsos.jatimprov.go.id',
      role: UserRole.superadmin,
    ),
    AppUser(
      id: 'ADM-002',
      username: 'kasubag.aset',
      name: 'Drs. H. Kasubag Aset, M.Si',
      nip: '19780512 200501 1 004',
      department: 'Subbag Tata Usaha & Pengelolaan Aset',
      email: 'kasubag.aset@dinsos.jatimprov.go.id',
      role: UserRole.admin,
    ),
    AppUser(
      id: 'USR-003',
      username: 'rendy.cahyono',
      name: 'Rendy Cahyono Putra',
      nip: '19950315 202012 1 002',
      department: 'Subbag Penyusunan Program & Anggaran',
      email: 'rendy.cahyono@dinsos.jatimprov.go.id',
      role: UserRole.user,
    ),
  ];

  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'Selamat Datang di SIP-K Dinsos Jatim',
      message:
          'Akun pegawai atas nama Alamsyah telah aktif dan siap digunakan untuk peminjaman kendaraan.',
      time: '14:05 WIB',
      fullDate: '01 September 2026, 14:05 WIB',
      createdAt: DateTime(2026, 9, 1, 14, 5),
      detailContent:
          'Sistem Informasi Pengelolaan Kendaraan (SIP-K) Dinas Sosial Provinsi Jawa Timur memfasilitasi kebutuhan kendaraan operasional dinas secara transparan dan akuntabel. Harap selalu menjaga kebersihan dan kelengkapan armada yang dipinjam.',
      referenceNumber: 'USR-2026-0901',
      type: NotificationType.welcome,
      isRead: false,
    ),
    AppNotification(
      id: '2',
      title: 'Pengajuan Peminjaman Terkirim',
      message:
          'Permohonan Toyota Innova Reborn (L 1023 SP) untuk perjalanan dinas ke Bakorwil Madiun berhasil diajukan.',
      time: '11:20 WIB',
      fullDate: '01 September 2026, 11:20 WIB',
      createdAt: DateTime(2026, 9, 1, 11, 20),
      detailContent:
          'Pengajuan Anda telah masuk ke dalam antrean verifikasi Sub Bagian Umum Dinsos Jatim. Surat Perintah Kerja (SPK) akan diterbitkan setelah disetujui oleh Kasubag.',
      referenceNumber: 'REQ/DINSOS/2026/09/0089',
      type: NotificationType.submitted,
      isRead: false,
    ),
    AppNotification(
      id: '3',
      title: 'Pengajuan Disetujui (SPK Terbit)',
      message:
          'Permohonan Isuzu Elf Minibus untuk kunjungan lapangan UPT Dinsos Malang telah disetujui.',
      time: '08:45 WIB',
      fullDate: '01 September 2026, 08:45 WIB',
      createdAt: DateTime(2026, 9, 1, 8, 45),
      detailContent:
          'Kasubag Umum telah menyetujui permohonan kendaraan dinas Anda. Silakan mengambil kunci kontak dan STNK asli di loket pengelola aset Gedung A dengan menunjukkan nomor SPK.',
      referenceNumber: 'SPK-5521/DINSOS/2026',
      type: NotificationType.approved,
      isRead: false,
    ),
    AppNotification(
      id: '4',
      title: 'Pengajuan Ditolak oleh Kasubag',
      message:
          'Permohonan Toyota Avanza Veloz (L 1455 EP) ditolak karena belum melampirkan Nota Dinas.',
      time: 'Kemarin',
      fullDate: '31 Agustus 2026, 16:15 WIB',
      createdAt: DateTime(2026, 8, 31, 16, 15),
      detailContent:
          'Catatan Kasubag: "Harap mengunggah kembali dokumen SPT atau Nota Dinas resmi yang sudah ditandatangani Kepala Bidang sebelum diverifikasi ulang."',
      referenceNumber: 'REJ-2026-0831-01',
      type: NotificationType.rejected,
      isRead: false,
    ),
    AppNotification(
      id: '5',
      title: 'Pengingat: Waktu Pengembalian Armada',
      message:
          'Unit Honda Vario 160 (L 3341 DS) harus dikembalikan ke Pool Dinas paling lambat pukul 17.00 WIB hari ini.',
      time: 'Kemarin',
      fullDate: '31 Agustus 2026, 13:00 WIB',
      createdAt: DateTime(2026, 8, 31, 13),
      detailContent:
          'Mohon pastikan tangki bahan bakar telah terisi sesuai kondisi saat pengambilan awal dan catat odometer terakhir pada formulir BAST pengembalian.',
      referenceNumber: 'REM-2026/08/3341',
      type: NotificationType.reminder,
      isRead: false,
    ),
    AppNotification(
      id: '6',
      title: 'Jadwal Pemeliharaan Rutin Armada',
      message:
          'Unit Yamaha NMAX 155 (L 4910 OS) sedang dalam jadwal servis berkala di bengkel rekanan.',
      time: '30 Ags 2026',
      fullDate: '30 Agustus 2026, 10:00 WIB',
      createdAt: DateTime(2026, 8, 30, 10),
      detailContent:
          'Unit tidak tersedia untuk peminjaman selama 2 hari kerja dalam rangka penggantian ban luar dan pelumas mesin berkala.',
      referenceNumber: 'MNT-NMAX-082026',
      type: NotificationType.maintenance,
      isRead: false,
    ),
    AppNotification(
      id: '7',
      title: 'Berita Acara Serah Terima (BAST) Selesai',
      message:
          'Pengembalian Toyota Innova Reborn (L 1023 SP) telah diverifikasi oleh petugas pool kendaraan.',
      time: '29 Ags 2026',
      fullDate: '29 Agustus 2026, 17:30 WIB',
      createdAt: DateTime(2026, 8, 29, 17, 30),
      detailContent:
          'Kondisi fisik unit dinilai lengkap, tangki BBM penuh, dan odometer akhir tercatat 45.200 KM. Riwayat transaksi peminjaman telah berstatus Selesai.',
      referenceNumber: 'BAST-2026-0829-04',
      type: NotificationType.approved,
      isRead: false,
    ),
    AppNotification(
      id: '8',
      title: 'Verifikasi Pengajuan Dipercepat',
      message:
          'Pengajuan armada untuk Satgas Bencana Linjamsos mendapatkan prioritas penugasan darurat.',
      time: '28 Ags 2026',
      fullDate: '28 Agustus 2026, 09:10 WIB',
      createdAt: DateTime(2026, 8, 28, 9, 10),
      detailContent:
          'Penugasan darurat logistik bantuan bencana telah diverifikasi secara langsung oleh Tim Pengelola Aset Provinsi.',
      referenceNumber: 'EMG-DINSOS-2026-08',
      type: NotificationType.approved,
      isRead: false,
    ),
    AppNotification(
      id: '9',
      title: 'Pembaruan Kebijakan BBM Operasional',
      message:
          'Mulai 1 September 2026, pengisian BBM kendaraan roda empat wajib menggunakan kartu voucher dinas resmi.',
      time: '26 Ags 2026',
      fullDate: '26 Agustus 2026, 14:00 WIB',
      createdAt: DateTime(2026, 8, 26, 14),
      detailContent:
          'Penggantian struk tunai secara mandiri ditiadakan kecuali dalam kondisi luar kota yang tidak memiliki SPBU mitra resmi.',
      referenceNumber: 'SE-KADIS-BBM-2026',
      type: NotificationType.welcome,
      isRead: false,
    ),
    AppNotification(
      id: '10',
      title: 'Pengajuan Dibatalkan oleh Sistem',
      message:
          'Permohonan peminjaman kedaluwarsa karena tidak ada konfirmasi selama 2x24 jam kerja.',
      time: '24 Ags 2026',
      fullDate: '24 Agustus 2026, 18:00 WIB',
      createdAt: DateTime(2026, 8, 24, 18),
      detailContent:
          'Sistem secara otomatis membatalkan antrean peminjaman kendaraan yang tidak dilengkapi berkas Nota Dinas dalam batas waktu yang ditentukan.',
      referenceNumber: 'EXP-DINSOS-2026-0824',
      type: NotificationType.rejected,
      isRead: false,
    ),
  ];

  void _handleCreateLoan(LoanRequest request) {
    setState(() {
      _loans.add(request);

      _notifications.insert(
        0,
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Pengajuan Terkirim',
          message:
              'Permohonan armada ${request.vehicleName} tujuan ${request.destination} sedang diproses oleh Kasubag Umum.',
          time: 'Baru saja',
          fullDate: '01 September 2026, 14:15 WIB',
          createdAt: DateTime.now(),
          detailContent:
              'Pengajuan armada ${request.vehicleName} dengan Nota Dinas ${request.officialNoteNumber} telah dikirim ke Kasubag Umum untuk proses verifikasi persetujuan SPK.',
          referenceNumber:
              'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          type: NotificationType.submitted,
        ),
      );
      _currentIndex = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoanHistoryScreen(
            loans: _loans,
            onLoanCancelled: (_) => setState(() {}),
          ),
        ),
      );
    });
  }

  void _handleVerification(LoanRequest loan, bool approved) {
    setState(() {
      final vehicle = _vehicles.firstWhere((v) => v.id == loan.vehicleId);
      if (approved) {
        loan.status = LoanStatus.disetujui;
        // Nomor Nota Dinas Resmi yang diterbitkan Kasubag
        loan.spkNumber = 'ND-${Random().nextInt(9000) + 1000}/DINSOS/2026';
        vehicle.status = VehicleStatus.digunakan;

        _notifications.insert(
          0,
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Pengajuan Disetujui (Nota Dinas Terbit)',
            message:
                'Permohonan armada ${loan.vehicleName} telah disetujui. Softfile Nota Dinas resmi telah tersedia untuk dicetak dan diserahkan ke Kasubag TU.',
            time: 'Hari ini',
            fullDate: '02 September 2026, 14:15 WIB',
            createdAt: DateTime.now(),
            detailContent:
                'Pengajuan peminjaman telah disahkan Kasubag Umum dengan Nomor Registrasi: ${loan.spkNumber}. Silakan cetak lembar Nota Dinas dari menu Riwayat atau Profil untuk diserahkan ke loket Kasubag TU saat pengambilan kunci kontak dan STNK unit armada.',
            referenceNumber: loan.spkNumber ?? '-',
            type: NotificationType.approved,
          ),
        );
      } else {
        loan.status = LoanStatus.ditolak;

        _notifications.insert(
          0,
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Pengajuan Ditolak',
            message:
                'Permohonan ${loan.vehicleName} ditolak. Silakan periksa kelengkapan administrasi atau pilih jadwal armada lain.',
            time: 'Hari ini',
            fullDate: '02 September 2026, 14:15 WIB',
            createdAt: DateTime.now(),
            detailContent:
                'Pengajuan ditolak oleh Kasubag Umum. Periksa kembali kelengkapan surat usulan atau silakan ajukan armada pengganti.',
            referenceNumber:
                'REJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            type: NotificationType.rejected,
          ),
        );
      }
    });
  }

  void _handleReturn(LoanRequest loan, int km, String fuel, String notes) {
    setState(() {
      loan.status = LoanStatus.selesai;
      loan.returnOdometer = km;
      loan.returnFuel = fuel;
      loan.returnNotes = notes;

      final vehicle = _vehicles.firstWhere((v) => v.id == loan.vehicleId);
      vehicle.status = VehicleStatus.tersedia;
    });
  }

  Widget _buildLoadingDashboard() {
    final bool isSuper = widget.role == 'superadmin';
    final bool isAdmin = widget.role == 'admin' || isSuper;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF24487A).withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo_sipk.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.directions_car_rounded,
                      size: 46,
                      color: Color(0xFF24487A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF24487A),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isAdmin
                      ? (isSuper
                            ? 'Menyiapkan Panel Superadministrator...'
                            : 'Menyiapkan Panel Kasubag Admin...')
                      : 'Memuat Dashboard SIP-K Jatim...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sinkronisasi armada dinas & status peminjaman...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDashboard) {
      return _buildLoadingDashboard();
    }

    final List<Widget> userPages = [
      UserDashboardScreen(
        userName: _currentUserProfile.name,
        vehicles: _vehicles,
        onNavigateTab: (idx) => setState(() => _currentIndex = idx),
        onSelectVehicle: (v) {
          setState(() {
            _selectedUnitForForm = v;
            _currentIndex = 2;
          });
        },
      ),
      CatalogScreen(
        vehicles: _vehicles,
        onSelectVehicle: (v) {
          setState(() {
            _selectedUnitForForm = v;
            _currentIndex = 2;
          });
        },
        onNavigateTab: (idx) => setState(() => _currentIndex = idx),
      ),
      LoanFlowScreen(
        vehicles: _vehicles,
        preselectedVehicle: _selectedUnitForForm,
        onSubmitLoan: _handleCreateLoan,
        onNavigateTab: (idx) => setState(() => _currentIndex = idx),
      ),
      NotificationScreen(
        notifications: _notifications,
        onClearAll: () {
          setState(() {
            for (var n in _notifications) {
              n.isRead = true;
            }
          });
        },
        onNavigateTab: (idx) => setState(() => _currentIndex = idx),
      ),
      ProfileScreen(
        loans: _loans,
        initialProfile: _currentUserProfile,
        onProfileUpdated: (up) => setState(() => _currentUserProfile = up),
        onNavigateTab: (idx) => setState(() => _currentIndex = idx),
      ),
    ];

    if (widget.role == 'admin' || widget.role == 'superadmin') {
      // Prioritaskan akun superadmin jika role adalah superadmin
      final bool isSuper = widget.role == 'superadmin';
      final activeUser = isSuper ? _appUsers[0] : _appUsers[1];

      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF24487A),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSuper
                    ? 'SIP-K • SUPERADMINISTRATOR'
                    : 'SIP-K • KASUBAG ADMIN',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                activeUser.name,
                style: const TextStyle(fontSize: 11, color: Color(0xFFBAE6FD)),
              ),
            ],
          ),
          actions: [
            // Tombol Switch Role Cepat (Superadmin <-> Admin) untuk mempermudah testing
            PopupMenuButton<String>(
              icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
              tooltip: 'Ganti Peran Admin untuk Demo',
              onSelected: (selectedRole) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(role: selectedRole),
                  ),
                );
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'superadmin',
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: Color(0xFFB45309),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Masuk sebagai Superadmin',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Color(0xFF24487A),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Masuk sebagai Kasubag Admin',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ],
        ),
        body: AdminApprovalScreen(
          requests: _loans,
          onVerify: _handleVerification,
          onReturn: _handleReturn,
          currentUser: activeUser,
          users: _appUsers,
          onAddUser: (newUser) => setState(() => _appUsers.add(newUser)),
          onUpdateUser: (updatedUser) => setState(() {}),
          onDeleteUser: (id) =>
              setState(() => _appUsers.removeWhere((u) => u.id == id)),

          // OPERAN KATALOG KENDARAAN (TAMBAHAN):
          vehicles: _vehicles,
          onAddVehicle: (newV) => setState(() => _vehicles.add(newV)),
          onUpdateVehicle: (updV) {
            setState(() {
              final index = _vehicles.indexWhere((v) => v.id == updV.id);
              if (index != -1) {
                _vehicles[index] = updV;
              }
            });
          },
          onDeleteVehicle: (id) =>
              setState(() => _vehicles.removeWhere((v) => v.id == id)),
        ),
      );
    }

    return Scaffold(
      body: userPages[_currentIndex],
      bottomNavigationBar: Container(
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
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavButton(Icons.home_filled, 'Beranda', 0),
                _buildNavButton(Icons.directions_car_rounded, 'Catalog', 1),

                // Tombol Pinjam Tengah yang Sejajar Sempurna
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _currentIndex == 2
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF24487A),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF24487A,
                                  ).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.assignment_add,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -5),
                          child: Text(
                            'Pinjam',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: _currentIndex == 2
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _currentIndex == 2
                                  ? const Color(0xFF24487A)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildNavButton(Icons.notifications_rounded, 'Notifikasi', 3),
                _buildNavButton(Icons.person_rounded, 'Profil', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF24487A)
                    : const Color(0xFF94A3B8),
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF24487A)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

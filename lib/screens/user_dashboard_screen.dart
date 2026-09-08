import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/screens/vehicle_detail_screen.dart';
import 'package:simodis_jatim/widgets/app_image.dart';

class UserDashboardScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Function(int) onNavigateTab;
  final Function(Vehicle) onSelectVehicle;

  const UserDashboardScreen({
    super.key,
    required this.vehicles,
    required this.onNavigateTab,
    required this.onSelectVehicle,
  });

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final PageController _newsPageController = PageController();
  int _currentNewsIndex = 0;

  // 6 Data Informasi & Pengumuman Dinsos Jatim (Gambar mudah diganti)
  final List<Map<String, String>> _newsList = [
    {
      'tag': 'PENGUMUMAN',
      'title': 'Uji Emisi & Servis Rutin Armada Tahap 1 Selesai',
      'desc':
          'Seluruh kendaraan dinas siap untuk penugasan luar kota dengan kondisi prima. Pemeriksaan mencakup sistem pengereman, oli mesin, dan kelayakan ban operasional.',
      'date': '01 Sep 2026',
      'image': 'assets/images/logo_sipk.png',
    },
    {
      'tag': 'OPERASIONAL',
      'title': 'Kewajiban Pengisian Form BAST Unit Kendaraan',
      'desc':
          'Harap mengisi catatan angka odometer dan level sisa BBM saat pengembalian unit ke pool dinas demi ketertiban administrasi aset kendaraan dinas.',
      'date': '28 Ags 2026',
      'image': 'assets/images/logo_sipk.png',
    },
    {
      'tag': 'KEGIATAN',
      'title': 'Penyaluran Logistik Tanggap Bencana Dinsos',
      'desc':
          'Armada minibus dan truk satgas Linjamsos standby 24 jam untuk kesiapsiagaan operasional bantuan tanggap bencana di seluruh wilayah Jawa Timur.',
      'date': '25 Ags 2026',
      'image': 'assets/images/logo_sipk.png',
    },
    {
      'tag': 'KEBIJAKAN',
      'title': 'Prosedur Baru Pengajuan Surat Perintah Kerja (SPK)',
      'desc':
          'Pastikan telah mengunggah scan Nota Dinas resmi yang telah ditandatangani Kepala Bidang sebelum mengajukan peminjaman armada ke Kasubag Umum.',
      'date': '20 Ags 2026',
      'image': 'assets/images/logo_sipk.png',
    },
    {
      'tag': 'PEMELIHARAAN',
      'title': 'Jadwal Penggantian Pelumas Armada Roda Dua',
      'desc':
          'Bagi pemegang unit sepeda motor dinas operasional diimbau membawa unit ke bengkel rekanan resmi Dinsos sesuai jadwal per semester.',
      'date': '15 Ags 2026',
      'image': 'assets/images/logo_sipk.png',
    },
    {
      'tag': 'KESELAMATAN',
      'title': 'Edukasi Protokol Berkendara Aman (Defensive Driving)',
      'desc':
          'Seluruh staf dan pengemudi dinas diwajibkan memeriksa kelengkapan P3K, segitiga pengaman, dan tekanan angin ban sebelum perjalanan dinas antar kota.',
      'date': '10 Ags 2026',
      'image': 'assets/images/logo_sipk.png',
    },
  ];

  @override
  void dispose() {
    _newsPageController.dispose();
    super.dispose();
  }

  void _showNewsDetailDialog(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar + Tombol Silang (X) di Pojok Kanan Atas
                Stack(
                  children: [
                    Container(
                      height: 190,
                      width: double.infinity,
                      color: const Color(0xFFEFF6FF),
                      child: AppImage(
                        source: item['image']!,
                        fit: BoxFit.cover,
                        placeholder: const Center(
                          child: Icon(
                            Icons.newspaper_rounded,
                            size: 50,
                            color: Color(0xFF24487A),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['tag']!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          Text(
                            item['date']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['desc']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                    ],
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. STICKY APP BAR (Logo Diperbesar & Teks Sejajar Proporsional)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                child: Container(
                  color: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            margin: const EdgeInsets.only(right: 10),
                            child: Image.asset(
                              'assets/images/logo_sipk.png',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, stack) => Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24487A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.directions_car_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SIP-K Dinsos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Provinsi Jawa Timur',
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
                      GestureDetector(
                        onTap: () => widget.onNavigateTab(4),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF24487A),
                              width: 1.5,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 17,
                            backgroundColor: Color(0xFF24487A),
                            child: Text(
                              'RC',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. KONTEN DASHBOARD
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BANNER SELAMAT DATANG
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF24487A),
                              Color(0xFF1E3A8A),
                              Color(0xFF3B82F6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF24487A,
                              ).withValues(alpha: 0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10,
                              bottom: -10,
                              child: Icon(
                                Icons.car_rental_rounded,
                                size: 110,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selamat Datang, Rendy Cahyono Putra',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFBAE6FD),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Temukan kendaraan dinas\nterbaik untuk tugas dinasmu',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                InkWell(
                                  onTap: () => widget.onNavigateTab(2),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Pinjam mudah & cepat',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF24487A),
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14,
                                          color: Color(0xFF24487A),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // INFORMASI & PENGUMUMAN
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Informasi & Pengumuman',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CARD INFORMASI (GAMBAR DI ATAS, TEKS DI BAWAH)
                    SizedBox(
                      height: 210,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: _newsPageController,
                            onPageChanged: (idx) =>
                                setState(() => _currentNewsIndex = idx),
                            itemCount: _newsList.length,
                            itemBuilder: (context, index) {
                              final item = _newsList[index];
                              return GestureDetector(
                                onTap: () => _showNewsDetailDialog(item),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 1. Gambar Informasi di Atas
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(15),
                                            ),
                                        child: Container(
                                          height: 105,
                                          width: double.infinity,
                                          color: const Color(0xFFEFF6FF),
                                          child: AppImage(
                                            source: item['image']!,
                                            fit: BoxFit.cover,
                                            placeholder: const Center(
                                              child: Icon(
                                                Icons.newspaper_rounded,
                                                color: Color(0xFF24487A),
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 2. Teks Informasi di Bawah
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 7,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFEFF6FF,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item['tag']!,
                                                      style: const TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFF2563EB,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    item['date']!,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFF94A3B8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                item['title']!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                item['desc']!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Tombol Navigasi Kiri
                          Positioned(
                            left: 6,
                            child: GestureDetector(
                              onTap: () {
                                if (_currentNewsIndex > 0) {
                                  _newsPageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  size: 20,
                                  color: _currentNewsIndex > 0
                                      ? const Color(0xFF24487A)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                          ),

                          // Tombol Navigasi Kanan
                          Positioned(
                            right: 6,
                            child: GestureDetector(
                              onTap: () {
                                if (_currentNewsIndex < _newsList.length - 1) {
                                  _newsPageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color:
                                      _currentNewsIndex < _newsList.length - 1
                                      ? const Color(0xFF24487A)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // INDIKATOR TITIK (6 DOTS)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_newsList.length, (index) {
                        final isActive = _currentNewsIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // ARMADA REKOMENDASI
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Armada Rekomendasi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 215,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.vehicles.length,
                        itemBuilder: (context, index) {
                          final item = widget.vehicles[index];
                          final isAvailable =
                              item.status == VehicleStatus.tersedia;

                          return Container(
                            width: 175,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                  child: Container(
                                    height: 95,
                                    width: double.infinity,
                                    color: const Color(0xFFEFF6FF),
                                    child: AppImage(
                                      source: item.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: Center(
                                        child: Icon(
                                          item.type == VehicleType.mobil
                                              ? Icons.directions_car_filled
                                              : Icons.two_wheeler_rounded,
                                          size: 44,
                                          color: const Color(0xFF24487A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.plateNumber,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 8,
                                                color: isAvailable
                                                    ? const Color(0xFF16A34A)
                                                    : const Color(0xFFDC2626),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isAvailable
                                                    ? 'Tersedia'
                                                    : 'Dipakai',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isAvailable
                                                      ? const Color(0xFF16A34A)
                                                      : const Color(0xFFDC2626),
                                                ),
                                              ),
                                            ],
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      VehicleDetailScreen(
                                                        vehicle: item,
                                                        onPinjam: widget
                                                            .onSelectVehicle,
                                                      ),
                                                ),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF24487A),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 10,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Delegate untuk Sticky Header
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 76.0;
  @override
  double get maxExtent => 76.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

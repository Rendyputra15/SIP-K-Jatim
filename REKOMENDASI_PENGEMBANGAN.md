# Catatan & Rekomendasi Pengembangan SIP-K Dinsos Jatim
*(Sistem Informasi Peminjaman Kendaraan Dinas Sosial Provinsi Jawa Timur)*

Dokumen ini memuat analisis status aplikasi saat ini serta daftar rekomendasi fitur, arsitektur teknis, dan perbaikan alur operasional untuk pengembangan aplikasi **SIP-K Jatim (simodis_jatim)** ke tahap produksi (*production-ready*).

---

## 1. Analisis Status Saat Ini (*Current State*)

Aplikasi telah memiliki desain antarmuka (UI/UX) yang modern, intuitif, dan responsif (mendukung tampilan Web/Desktop dan Mobile). Alur fungsional simulasi (*mockup*) sudah mencakup:
- Multi-role: **Superadmin** (Kepala Dinas / Administrator Pusat), **Admin** (Kasubag TU & Aset), dan **Pegawai / Pemohon**.
- Alur approval persetujuan bertingkat, monitoring armada, dan daftar riwayat.
- Pengajuan permohonan peminjaman dengan upload bukti nota dinas / surat tugas.

### Keterbatasan yang Perlu Dibenahi:
1. **Penyimpanan Data Masih In-Memory**: Data kendaraan, user, notifikasi, dan permohonan disimpan dalam memori lokal widget (*in-memory* / `List` lokal). Data akan kembali ke kondisi awal setiap kali aplikasi di-refresh atau di-restart.
2. **Belum Ada Backend & API**: Autentikasi dan logika bisnis masih di-*hardcode* di sisi *client-side*.
3. **Prop Drilling**: Pengiriman data antar layar masih mengandalkan konstruktor berantai (`HomeScreen` -> `UserDashboardScreen` -> `AdminApprovalScreen`).
4. **Ukuran File Terlalu Besar**: File `admin_approval_screen.dart` telah mencapai lebih dari 2.500 baris kode dalam satu berkas sehingga perlu modularisasi (*refactoring*).

---

## 2. Roadmap Rekomendasi Pengembangan

### A. Prioritas 1 (Krusial / Fondasi Teknis - P0)

1. **Integrasi Backend & Database Persisten**
   - **Rekomendasi Teknologi**: REST API menggunakan **Laravel / Node.js (NestJS/Express) / Supabase / Firebase**, dengan database relasional (**PostgreSQL / MySQL**).
   - **Entitas Utama**: `users`, `vehicles`, `loan_requests`, `inspection_checklists`, `notifications`, `logs_activity`.
   - **Konektivitas**: Tambahkan dependensi `dio` atau `http` pada `pubspec.yaml` untuk komunikasi API, serta model JSON serializer (`json_serializable`).

2. **State Management Terpusat**
   - Menggantikan *stateful widget manual* dan *prop-drilling* dengan salah satu state management standar industri:
     - **Bloc / Cubit** (direkomendasikan untuk aplikasi enterprise/pemerintahan yang membutuhkan arsitektur terstruktur ketat), atau
     - **Riverpod / Provider** (ringan, mudah diuji, dan modern).

3. **Autentikasi & Sesi Login Aman**
   - Implementasi autentikasi berbasis **JWT (JSON Web Token)** dengan *Access Token* dan *Refresh Token*.
   - Simpan token di media penyimpanan aman perangkat menggunakan dependensi `flutter_secure_storage` atau `shared_preferences`.
   - Implementasi auto-login (cek validitas token saat aplikasi dibuka).

4. **Deteksi & Pencegahan Jadwal Bentrok (*Conflict Booking Check*)**
   - Pada form peminjaman, buat validasi kalender: jika kendaraan X sudah disetujui pada rentang tanggal/jam yang diminta, unit tersebut otomatis tidak dapat dipilih atau bertanda *"Sudah Dibooking"*.
   - Tambahkan *time-slot picker* yang jelas (tanggal & jam mulai s.d. tanggal & jam selesai).

---

### B. Prioritas 2 (Fitur Operasional Kendaraan Dinas - P1)

1. **Digital Berita Acara Serah Terima (BAST) & Checklist Fisik (Check-in / Check-out)**
   - Saat unit diambil:
     - Foto odometer awal (kilometer kendaraan).
     - Indikator sisa bahan bakar (BBM).
     - Foto 4 sisi kendaraan (depan, belakang, sisi kanan, sisi kiri) untuk mencatat kondisi fisik sebelum berangkat.
   - Saat unit dikembalikan:
     - Foto odometer akhir untuk menghitung total jarak tempuh dinas (KM).
     - Catatan kondisi kendaraan (apakah ada kendala mesin, lecet, atau kebersihan).
   - Ini sangat penting untuk akuntabilitas pertanggungjawaban aset daerah.

2. **Ekspor & Cetak Surat Izin Jalan / Bukti Peminjaman (PDF & QR Code)**
   - Menggunakan package `pdf` dan `printing`.
   - Otomatis menghasilkan dokumen **Surat Tugas / Izin Peminjaman Kendaraan Dinas** berformat resmi Pemerintah Provinsi Jawa Timur.
   - Dilengkapi **QR Code unik** yang dapat di-*scan* oleh petugas keamanan (Satpam di gerbang pool kendaraan) untuk verifikasi izin keluar/masuk kendaraan tanpa berkas manual.

3. **Notifikasi Real-time & Pengingat Tenggat Pengembalian (*Push Notifications*)**
   - Integrasi **Firebase Cloud Messaging (FCM)**.
   - Notifikasi kepada Kasubag/Admin saat ada permohonan baru yang masuk.
   - Notifikasi kepada Pemohon saat permohonan Disetujui / Ditolak.
   - Notifikasi otomatis H-2 jam sebelum masa peminjaman berakhir agar peminjam segera mengembalikan unit tepat waktu.

4. **Pencatatan Biaya Operasional Lapangan (BBM & Tol)**
   - Form sederhana bagi pemohon/driver untuk mengunggah foto struk pembelian BBM dan saldo e-Toll operasional selama perjalanan dinas.
   - Mempermudah bagian keuangan & perlengkapan dalam proses *reimbursement* atau SPJ dinas.

5. **Pengingat Servis Berkala & Jatuh Tempo Pajak STNK**
   - Fitur monitoring khusus Admin Aset:
     - Peringatan otomatis jika odometer telah mencapai kelipatan 5.000 / 10.000 km (jadwal ganti oli/servis berkala).
     - Peringatan H-30 hari sebelum tanggal jatuh tempo Pajak STNK (tahunan) dan Uji Kir / Ganti Plat (5 tahunan).

---

### C. Prioritas 3 (Peningkatan Lanjutan & Pengalaman Pengguna - P2)

1. **Validasi Lokasi Pengembalian (Geotagging / Geofencing)**
   - Menggunakan package `geolocator`.
   - Tombol konfirmasi pengembalian unit oleh pemohon hanya dapat diaktifkan jika posisi GPS ponsel berada dalam radius kantor Dinas Sosial Prov. Jatim (atau pool resmi).

2. **Laporan & Rekapitulasi Eksekutif (Export Excel / CSV)**
   - Dashboard analitik untuk Kasubag / Kepala Dinas:
     - Kendaraan mana yang paling sering digunakan.
     - Bidang/divisi yang paling aktif meminjam armada.
     - Total jarak tempuh dan konsumsi bahan bakar bulanan.
     - Fitur download rekap laporan bulanan dalam format Excel/PDF untuk laporan LPJ aset.

3. **Opsi Integrasi SSO SIMPEG / Satu Data Jatim**
   - Jika tersedia API kepegawaian internal BKD / Diskominfo Jatim, login dapat dihubungkan dengan Single Sign-On (SSO) akun ASN/Non-ASN resmi Pemprov Jawa Timur.

---

### D. Rekomendasi Kualitas Kode & Arsitektur (*Code Cleanliness*)

1. **Modularisasi Layar Besar (`admin_approval_screen.dart`)**
   - Pecah file menjadi berkas-berkas widget terpisah:
     - `lib/screens/admin/tabs/approval_requests_tab.dart`
     - `lib/screens/admin/tabs/vehicle_monitoring_tab.dart`
     - `lib/screens/admin/tabs/user_management_tab.dart`
     - `lib/screens/admin/widgets/return_inspection_dialog.dart`
2. **Penyusunan Struktur Folder Berbasis Fitur (*Feature-First* atau *Clean Architecture*)**:
   ```text
   lib/
   ├── core/           # Tema, utilitas, konstanta, network client
   ├── data/           # Repositori, sumber data (API/Local DB), model DTO
   ├── logic/          # Bloc / Riverpod provider / Controllers
   └── presentation/   # Layar (screens), komponen (widgets)
   ```
3. **Pengujian Otomatis (*Unit & Widget Testing*)**:
   - Menulis pengujian logika validasi peminjaman, kalkulasi kapasitas, dan status transisi di folder `test/`.

---

*Disusun untuk Tim Pengembang SIP-K Dinsos Jatim.*

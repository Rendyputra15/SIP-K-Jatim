# Catatan & Rekomendasi Pengembangan SIP-K Dinsos Jatim
*(Sistem Informasi Peminjaman Kendaraan Dinas Sosial Provinsi Jawa Timur)*

Dokumen ini memuat daftar **rekomendasi perbaikan dan penambahan fitur khusus untuk sisi Front-End (UI/UX)**, status fitur yang telah selesai diimplementasikan, serta peta jalan teknis untuk pengembangan aplikasi **SIP-K Jatim (simodis_jatim)**.

---

## 1. Daftar Rekomendasi Peningkatan & Penambahan Front-End (Urutan Prioritas)

Berikut adalah daftar rekomendasi fitur antarmuka (Front-End) yang perlu ditambahkan atau disempurnakan:

### 1. Stepper / Timeline Visual Lacak Permohonan (*Loan Tracking Stepper*)
- **Deskripsi**: Di halaman dashboard pemohon (Pegawai) dan detail berkas, tambahkan komponen visual *Step Indicator / Tracking Timeline* vertikal atau horizontal.
- **Tahapan Alur**:
  1. `Berkas Diajukan` (Menunggu Verifikasi)
  2. `Disetujui Kasubag` (Penerbitan Nomor SPK)
  3. `Pengambilan Kunci & Unit` (Penyerahan Kendaraan di Pool)
  4. `Sedang Bertugas / Berdinas`
  5. `Pemeriksaan Fisik & BAST Selesai` (Pengembalian Sukses)
- **Manfaat**: Pegawai/pemohon dapat mengetahui secara instan posisi permohonannya tanpa harus bolak-balik bertanya ke bagian perlengkapan/Kasubag.

---

### 2. Time-Picker & Deteksi Visual Jadwal Bentrok di Form Pengajuan (*Conflict Schedule Alert*)
- **Deskripsi**: Saat ini formulir hanya memilih tanggal mulai dan selesai.
- **Peningkatan yang Dibutuhkan**:
  - Tambahkan pilihan **Jam Berangkat** dan **Jam Selesai** (*Time-Slot Picker*).
  - Berikan **peringatan otomatis (*real-time warning alert*)** berwarna merah jika unit kendaraan yang dipilih sudah memiliki jadwal disetujui di rentang jam/tanggal yang sama.
  - Tampilkan rekomendasi kendaraan lain yang setipe dan sedang *tersedia* pada jam tersebut.
- **Manfaat**: Mencegah pemohon mengajukan armada yang sedang dipakai pegawai lain.

---

### 3. Digital BAST & Checklist Inspeksi Fisik Kendaraan (Foto 4 Sisi)
- **Deskripsi**: Formulir digital saat serah terima kunci dan pengembalian kendaraan.
- **Komponen UI**:
  - Slot upload **Foto 4 Sisi Kendaraan** (Depan, Belakang, Sisi Kanan, Sisi Kiri) menggunakan kamera ponsel atau galeri.
  - Indikator slider visual untuk **Sisa Bahan Bakar (BBM)** (E, 1/4, 1/2, 3/4, Full).
  - Checklist perlengkapan unit: STNK asli, Kunci cadangan, Ban serep, Dongkrak, Toolkit, Helm/Jas Hujan (untuk motor dinas).
  - Kanvas tanda tangan digital (*Digital Signature Pad*) untuk peminjam dan petugas pool.
- **Manfaat**: Transparansi penuh dan pertanggungjawaban aset daerah bila terjadi kerusakan fisik atau kelalaian.

---

### 4. Surat Izin Jalan Digital Lengkap dengan QR Code (*Gate Pass Verification*)
- **Deskripsi**: Halaman khusus atau kartu pop-up yang menghasilkan **Surat Tugas / Surat Perintah Kerja (SPK) Peminjaman Kendaraan Dinas** dalam format digital.
- **Komponen UI**:
  - Dilengkapi **QR Code unik** yang dapat di-*scan* langsung oleh petugas keamanan (Satpam di gerbang pos pool dinas) untuk memvalidasi izin keluar-masuk kendaraan tanpa berkas kertas manual.
  - Tombol aksi *"Simpan Gambar / Bagikan ke WhatsApp / Cetak PDF"*.

---

### 5. Skeleton Loading (Shimmer Effect) & Micro-Animations
- **Deskripsi**: Menggantikan lingkaran putar standar (`CircularProgressIndicator`) dengan animasi bayangan abu-abu berkilau (*Shimmer placeholder*).
- **Penerapan**:
  - Pada kartu katalog kendaraan saat data dimuat.
  - Pada daftar tabel laporan, riwayat pengajuan, dan kartu statistik dashboard.
  - Tambahkan animasi transisi halus (*Hero animation*) saat kartu kendaraan di katalog diketuk menuju halaman detail armada.
- **Manfaat**: Tampilan terasa sangat mulus, responsif, dan profesional (*Google/Apple Material Design level*).

---

### 6. Filter Lanjutan & Pengurutan (*Sorting*) Multi-Kriteria di Katalog Armada
- **Deskripsi**: Melengkapi bilah pencarian langsung yang sudah ada dengan tombol filter cepat (*Quick Filter Chips*):
  - **Tipe**: `Semua`, `Mobil MPV/SUV`, `Minibus/Elf`, `Sepeda Motor`.
  - **Status**: `Hanya yang Tersedia`, `Sedang Berdinas`, `Dalam Perbaikan/Servis`.
  - **Kapasitas**: Pilihan penumpang (`1-2 Orang`, `4-5 Orang`, `> 7 Orang`).
  - **Urutan (Sorting)**: Berdasarkan nama armada (A-Z), sisa bahan bakar tertinggi, atau frekuensi pemakaian.

---

### 7. Form Catatan Biaya Lapangan (Struk BBM, Tol, & Parkir Dinas)
- **Deskripsi**: Formulir tambahan di riwayat peminjaman bagi pegawai/driver yang sedang berdinas.
- **Fitur UI**:
  - Tombol unggah foto struk pembelian BBM dan e-Toll.
  - Input jumlah nominal (Rp) dan otomatis menghitung total pengeluaran dinas lapangan.
  - Tombol ekspor rekap biaya ke PDF untuk lampiran SPJ/reimbursement ke bagian keuangan dinas.

---

### 8. Pratinjau Cetak Resmi (*Print Preview Kop Surat Pemprov Jatim*)
- **Deskripsi**: Halaman dialog pratinjau cetak (*Print Preview*) yang menampilkan format surat resmi dengan kop surat:
  - *Pemerintah Provinsi Jawa Timur - Dinas Sosial*.
  - Menampilkan layout siap cetak ukuran kertas A4 / F4.
  - Tombol langsung print ke printer kantor melalui browser web atau simpan PDF resmi.

---

### 9. Pratinjau Interaktif Bukti Nota Dinas & SIM (*Interactive Document Zoom & PDF Viewer*)
- **Deskripsi**: Saat Admin atau Kasubag memeriksa berkas pengajuan di halaman verifikasi:
  - Sediakan fitur *Pinch-to-Zoom / Fullscreen Viewer* untuk foto KTP, SIM, dan Nota Dinas agar teks kecil pada surat disposisi dapat dibaca dengan tajam.
  - Dukungan untuk membuka file PDF surat dinas langsung di dalam aplikasi tanpa harus keluar dari layar verifikasi.

---

### 10. Pengingat Notifikasi Servis & Pajak STNK (*Maintenance & Tax Reminder Widget*)
- **Deskripsi**: Widget pengingat khusus di dashboard admin:
  - Kartu notifikasi berwarna oranye jika ada armada yang jarak tempuhnya telah mendekati kelipatan 5.000 / 10.000 KM (waktu ganti oli dan servis rutin).
  - Kartu peringatan merah jika ada masa berlaku Pajak STNK atau Uji Kir kendaraan dinas yang jatuh tempo dalam 30 hari ke depan.

---

### 11. Shortcut Keyboard & Optimalisasi Navigasi untuk Pengguna Web Desktop
- **Deskripsi**: Mempermudah staf Kasubag dan Superadmin yang menggunakan PC/Laptop kantor:
  - Tombol pintas `/` atau `Ctrl+F` untuk langsung fokus ke bilah pencarian katalog/berkas.
  - Tombol `Esc` untuk menutup dialog/pop-up secara instan.
  - Navigasi tabel menggunakan tombol panah keyboard.

---

### 12. Mode Gelap & Mode Terang (*Theme Mode Switcher*)
- **Deskripsi**: Tombol toggle tema di profil admin/user untuk berpindah antara tema terang (*Light Mode*) dan tema gelap (*Dark Mode*).
- **Manfaat**: Kenyamanan mata bagi administrator yang bekerja di depan layar komputer dalam durasi panjang.

---

## 2. Fitur yang Telah Berhasil Diimplementasikan (*Changelog Terkini*)

Berikut adalah fitur-fitur yang telah berhasil dibangun dan diuji pada aplikasi:

1. **Sidebar Tema Putih & Elegan (Desktop & Web)**:
   - Latar belakang putih bersih dengan border halus.
   - Logo resmi SIP-K di samping teks judul `SIP-K DINSOS`.
   - Ikon menu, hamburger menu, nama akun, dan seluruh teks navigasi berwarna hitam pekat (`Color(0xFF1E293B)`).
2. **Halaman Baru Analisis & Grafik Antrean Masuk**:
   - Terbuka otomatis saat mengetuk card **"Antrean Masuk"** di dashboard Superadmin & Admin.
   - Dilengkapi filter periode dinamis: **Harian (7 Hari)**, **Mingguan (Per Minggu)**, dan **Bulanan (12 Bulan)**.
   - Diagram batang interaktif dengan angka riil di atas batang dan rincian data saat batang diklik.
   - Sebaran permohonan per bidang (Linjamsos, Rehsos, PFM, Keuangan, Program) dan jenis armada.
   - Daftar permohonan antrean aktif yang siap diverifikasi di tempat.
3. **Menu Jadwal Kalender di Sidebar Superadmin & Admin**:
   - Kalender penanggalan Indonesia (Senin – Minggu) dengan penanda hari ini dan tanggal terpilih.
   - Titik indikator penugasan (Hijau untuk tugas aktif, Kuning untuk permohonan menunggu).
   - Ringkasan harian unit yang **Siap** vs unit yang **Jalan/Bertugas**.
   - Filter tipe armada (Semua, Mobil, Motor).
4. **Menu Laporan Khusus Superadmin**:
   - Filter periode dinamis (Bulan Ini, Bulan Lalu, Triwulan 3, Tahun Penuh).
   - Tombol ekspor dokumen ke format PDF dan Excel (XLSX).
   - Kartu metrik: Total Permohonan, Tuntas, Total Armada Aktif, dan Bidang Teraktif.
   - Grafik tingkat utilisasi dan log rekapitulasi penugasan.
5. **Katalog Armada Interaktif**:
   - Bilah pencarian instan (nama unit / plat nomor).
   - Chip indikator sisa BBM dan jenis transmisi (Matic / Manual) langsung di kartu katalog tanpa harus membuka detail.
6. **Pop-up Izin Notifikasi Sistem**:
   - Terhubung langsung dengan pengaturan izin HP (*System Notification Permission Dialog*).
   - Penyesuaian dependensi `permission_handler: 11.3.1` agar proses build Android Gradle berjalan lancar tanpa error DSL.

---

## 3. Rekomendasi Arsitektur Backend & Database (Tahap Lanjutan)

1. **Integrasi RESTful API / GraphQL**:
   - Menggunakan framework backend seperti **Laravel / Express.js / NestJS / Supabase**.
   - Database relasional (**PostgreSQL / MySQL**) dengan skema tabel: `users`, `vehicles`, `loan_requests`, `maintenance_logs`, `notifications`.
2. **Autentikasi Aman**:
   - Autentikasi berbasis token JWT (*Access & Refresh Token*) yang tersimpan aman di `flutter_secure_storage`.
   - Opsi SSO (*Single Sign-On*) dengan sistem kepegawaian BKD / Pemprov Jawa Timur.
3. **State Management Terpusat**:
   - Migrasi state manual ke **Bloc / Cubit** atau **Riverpod** untuk memisahkan logika bisnis dari tampilan antarmuka.

---

*Disusun untuk Tim Pengembang Aplikasi SIP-K Dinas Sosial Provinsi Jawa Timur.*

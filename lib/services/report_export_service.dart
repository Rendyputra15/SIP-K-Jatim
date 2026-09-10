// lib/services/report_export_service.dart
// Layanan untuk menghasilkan dan mengunduh laporan PDF dan Excel
// Mendukung cross-platform (Web, Android, iOS, Desktop)

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/services/file_saver_helper.dart';

class ReportExportService {
  /// Unduh laporan sebagai PDF di browser
  static Future<void> exportPdf({
    required List<LoanRequest> requests,
    required List<Vehicle> vehicles,
    required String period,
  }) async {
    final pdf = pw.Document();

    // Hitung statistik
    final completed = requests
        .where((r) =>
            r.status == LoanStatus.selesai ||
            r.status == LoanStatus.disetujui ||
            r.status == LoanStatus.approved)
        .toList();
    final rejected = requests
        .where((r) =>
            r.status == LoanStatus.ditolak || r.status == LoanStatus.rejected)
        .toList();
    final pending = requests
        .where((r) =>
            r.status == LoanStatus.menunggu || r.status == LoanStatus.pending)
        .toList();

    final deptCount = <String, int>{};
    for (final r in requests) {
      final dept = r.department.isNotEmpty ? r.department : 'Dinsos Jatim';
      deptCount[dept] = (deptCount[dept] ?? 0) + 1;
    }
    String topDept = deptCount.isNotEmpty
        ? (deptCount.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key
        : '-';

    // Warna tema
    const primaryColor = PdfColor.fromInt(0xFF1E3A5F);
    const accentColor = PdfColor.fromInt(0xFF2563EB);
    const successColor = PdfColor.fromInt(0xFF10B981);
    const errorColor = PdfColor.fromInt(0xFFEF4444);
    const warningColor = PdfColor.fromInt(0xFFF59E0B);
    const lightGrey = PdfColor.fromInt(0xFFF8FAFC);
    const borderGrey = PdfColor.fromInt(0xFFE2E8F0);
    const textPrimary = PdfColor.fromInt(0xFF0F172A);
    const textSecondary = PdfColor.fromInt(0xFF64748B);
    const white = PdfColors.white;

    // Helper: format tanggal
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    // Helper: warna status
    PdfColor statusColor(LoanStatus s) {
      switch (s) {
        case LoanStatus.disetujui:
        case LoanStatus.approved:
          return successColor;
        case LoanStatus.selesai:
          return accentColor;
        case LoanStatus.ditolak:
        case LoanStatus.rejected:
          return errorColor;
        default:
          return warningColor;
      }
    }

    String statusLabel(LoanStatus s) {
      switch (s) {
        case LoanStatus.disetujui:
        case LoanStatus.approved:
          return 'DISETUJUI';
        case LoanStatus.selesai:
          return 'SELESAI (BAST)';
        case LoanStatus.ditolak:
        case LoanStatus.rejected:
          return 'DITOLAK';
        case LoanStatus.dibatalkan:
          return 'DIBATALKAN';
        default:
          return 'MENUNGGU';
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (ctx) {
          if (ctx.pageNumber > 1) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: const pw.BoxDecoration(color: primaryColor),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'LAPORAN ARMADA DINSOS JATIM – $period',
                    style: pw.TextStyle(
                      color: white,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Hal. ${ctx.pageNumber} / ${ctx.pagesCount}',
                    style: const pw.TextStyle(color: white, fontSize: 8),
                  ),
                ],
              ),
            );
          }
          return pw.SizedBox();
        },
        footer: (ctx) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 12),
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: borderGrey)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Dokumen ini digenerate oleh Sistem SIP-K • Rahasia / Internal Dinsos Prov. Jawa Timur',
                style: const pw.TextStyle(color: textSecondary, fontSize: 7),
              ),
              pw.Text(
                'Hal. ${ctx.pageNumber} / ${ctx.pagesCount}',
                style: const pw.TextStyle(color: textSecondary, fontSize: 7),
              ),
            ],
          ),
        ),
        build: (ctx) => [
          // ─── HEADER UTAMA ───────────────────────────────────
          pw.Container(
            width: double.infinity,
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [primaryColor, accentColor],
                begin: pw.Alignment.centerLeft,
                end: pw.Alignment.centerRight,
              ),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN & REKAPITULASI OPERASIONAL ARMADA DINAS',
                  style: pw.TextStyle(
                    color: white,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Dinas Sosial Provinsi Jawa Timur – Sistem Informasi Peminjaman Kendaraan (SIP-K)',
                  style: const pw.TextStyle(color: white, fontSize: 9),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0x26FFFFFF),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(12)),
                      ),
                      child: pw.Text(
                        'Periode: $period',
                        style: pw.TextStyle(
                          color: white,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      'Tanggal Cetak: ${fmt(DateTime.now())}',
                      style: const pw.TextStyle(color: white, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ─── RINGKASAN STATISTIK (4 KOTAK) ──────────────────
          pw.Text(
            'RINGKASAN STATISTIK PERIODE',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: textPrimary,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _pdfStatCard('Total Permohonan', '${requests.length}',
                  'Seluruh berkas', accentColor),
              pw.SizedBox(width: 6),
              _pdfStatCard('Disetujui & Tuntas', '${completed.length}',
                  'Selesai / Aktif', successColor),
              pw.SizedBox(width: 6),
              _pdfStatCard('Menunggu Proses', '${pending.length}',
                  'Belum diproses', warningColor),
              pw.SizedBox(width: 6),
              _pdfStatCard(
                  'Ditolak', '${rejected.length}', 'Tidak disetujui', errorColor),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              _pdfStatCard('Total Armada Pool',
                  '${vehicles.length} Unit', 'Mobil & Motor', primaryColor),
              pw.SizedBox(width: 6),
              _pdfStatCard('Bidang Teraktif',
                  topDept.length > 18 ? '${topDept.substring(0, 17)}...' : topDept,
                  'Peminjam terbanyak',
                  const PdfColor.fromInt(0xFF8B5CF6)),
              pw.SizedBox(width: 6),
              pw.Expanded(child: pw.SizedBox()),
              pw.SizedBox(width: 6),
              pw.Expanded(child: pw.SizedBox()),
            ],
          ),
          pw.SizedBox(height: 16),

          // ─── TABEL UTILISASI ARMADA ──────────────────────────
          pw.Text(
            'TINGKAT UTILISASI ARMADA',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: textPrimary,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: borderGrey, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: primaryColor),
                children: [
                  _pdfTableCell('Nama Kendaraan', isHeader: true),
                  _pdfTableCell('No. Plat', isHeader: true),
                  _pdfTableCell('Tipe', isHeader: true),
                  _pdfTableCell('Transmisi / Kapasitas', isHeader: true),
                  _pdfTableCell('Jml. Penugasan', isHeader: true),
                ],
              ),
              // Data rows
              for (final v in vehicles)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: vehicles.indexOf(v).isEven ? lightGrey : white,
                  ),
                  children: [
                    _pdfTableCell(v.name),
                    _pdfTableCell(v.plateNumber),
                    _pdfTableCell(
                        v.type == VehicleType.mobil ? 'Mobil' : 'Motor'),
                    _pdfTableCell('${v.transmission} / ${v.capacity} Seat'),
                    _pdfTableCell(
                      '${requests.where((r) => r.vehicleName.contains(v.name)).length}x',
                      align: pw.TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 16),

          // ─── TABEL RIWAYAT PERMOHONAN ────────────────────────
          pw.Text(
            'DETAIL RIWAYAT PERMOHONAN PEMINJAMAN',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: textPrimary,
            ),
          ),
          pw.SizedBox(height: 8),
          if (requests.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              alignment: pw.Alignment.center,
              child: pw.Text('Belum ada data permohonan pada periode ini.',
                  style: const pw.TextStyle(color: textSecondary, fontSize: 9)),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: borderGrey, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(18),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(2),
                5: const pw.FlexColumnWidth(1.5),
                6: const pw.FlexColumnWidth(1.2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: primaryColor),
                  children: [
                    _pdfTableCell('#', isHeader: true),
                    _pdfTableCell('Nama Pemohon', isHeader: true),
                    _pdfTableCell('Bidang', isHeader: true),
                    _pdfTableCell('Kendaraan', isHeader: true),
                    _pdfTableCell('Tujuan', isHeader: true),
                    _pdfTableCell('Periode', isHeader: true),
                    _pdfTableCell('Status', isHeader: true),
                  ],
                ),
                for (int i = 0; i < requests.length; i++)
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: i.isEven ? lightGrey : white,
                    ),
                    children: [
                      _pdfTableCell('${i + 1}', align: pw.TextAlign.center),
                      _pdfTableCell(requests[i].borrowerName),
                      _pdfTableCell(requests[i].department.isNotEmpty
                          ? requests[i].department
                          : 'Dinsos Jatim'),
                      _pdfTableCell(requests[i].vehicleName),
                      _pdfTableCell(requests[i].destination),
                      _pdfTableCell(
                          '${fmt(requests[i].startDate)}\n${fmt(requests[i].endDate)}'),
                      _pdfStatusCell(
                          statusLabel(requests[i].status),
                          statusColor(requests[i].status)),
                    ],
                  ),
              ],
            ),

          pw.SizedBox(height: 20),

          // ─── CATATAN KAKI RESMI ──────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: lightGrey,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: borderGrey),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'KETERANGAN & PERNYATAAN DOKUMEN',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  '1. Dokumen ini merupakan hasil cetak laporan resmi dari Sistem Informasi Peminjaman Kendaraan (SIP-K) Dinas Sosial Provinsi Jawa Timur.\n'
                  '2. Data yang tercantum bersumber dari basis data sistem per tanggal cetak.\n'
                  '3. Laporan ini bersifat rahasia dan hanya untuk keperluan internal instansi.\n'
                  '4. Segala perubahan data setelah tanggal cetak tidak tercermin dalam dokumen ini.',
                  style: const pw.TextStyle(color: textSecondary, fontSize: 7.5),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Surabaya, ${fmt(DateTime.now())}',
                          style:
                              const pw.TextStyle(color: textPrimary, fontSize: 8),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Kasubag Umum & Kepegawaian',
                          style: pw.TextStyle(
                            color: textPrimary,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 36),
                        pw.Container(
                            width: 120, height: 0.5,
                            color: textPrimary),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          '(_________________________)',
                          style:
                              const pw.TextStyle(color: textSecondary, fontSize: 8),
                        ),
                        pw.Text(
                          'NIP. ____________________',
                          style:
                              const pw.TextStyle(color: textSecondary, fontSize: 7),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    _downloadFile(bytes, 'SIPK-LAPORAN-ARMADA-${_periodToFileName(period)}.pdf',
        'application/pdf');
  }

  /// Unduh laporan sebagai Excel di browser
  static Future<void> exportExcel({
    required List<LoanRequest> requests,
    required List<Vehicle> vehicles,
    required String period,
  }) async {
    final excel = Excel.createExcel();

    // ─── SHEET 1: RINGKASAN ──────────────────────────────────
    final summarySheet = excel['Ringkasan'];
    excel.setDefaultSheet('Ringkasan');

    final completed = requests
        .where((r) =>
            r.status == LoanStatus.selesai ||
            r.status == LoanStatus.disetujui ||
            r.status == LoanStatus.approved)
        .length;
    final rejected = requests
        .where((r) =>
            r.status == LoanStatus.ditolak || r.status == LoanStatus.rejected)
        .length;
    final pending = requests
        .where((r) =>
            r.status == LoanStatus.menunggu || r.status == LoanStatus.pending)
        .length;

    final deptCount = <String, int>{};
    for (final r in requests) {
      final dept = r.department.isNotEmpty ? r.department : 'Dinsos Jatim';
      deptCount[dept] = (deptCount[dept] ?? 0) + 1;
    }
    String topDept = deptCount.isNotEmpty
        ? (deptCount.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key
        : '-';

    // Helper styles
    CellStyle headerStyle() => CellStyle(
          bold: true,
          fontColorHex: ExcelColor.white,
          backgroundColorHex: ExcelColor.fromHexString('#1E3A5F'),
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          fontSize: 11,
        );
    CellStyle subHeaderStyle() => CellStyle(
          bold: true,
          fontColorHex: ExcelColor.fromHexString('#1E3A5F'),
          backgroundColorHex: ExcelColor.fromHexString('#EFF6FF'),
          horizontalAlign: HorizontalAlign.Left,
          fontSize: 10,
        );

    // Judul
    summarySheet.merge(
        CellIndex.indexByString('A1'), CellIndex.indexByString('F1'));
    summarySheet.cell(CellIndex.indexByString('A1')).value =
        TextCellValue('LAPORAN & REKAPITULASI OPERASIONAL ARMADA DINAS');
    summarySheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#0F2042'),
      horizontalAlign: HorizontalAlign.Center,
    );

    summarySheet.merge(
        CellIndex.indexByString('A2'), CellIndex.indexByString('F2'));
    summarySheet.cell(CellIndex.indexByString('A2')).value =
        TextCellValue('Dinas Sosial Provinsi Jawa Timur – Sistem SIP-K');
    summarySheet.cell(CellIndex.indexByString('A2')).cellStyle = CellStyle(
      fontSize: 10,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#1E3A5F'),
      horizontalAlign: HorizontalAlign.Center,
    );

    summarySheet.merge(
        CellIndex.indexByString('A3'), CellIndex.indexByString('F3'));
    summarySheet.cell(CellIndex.indexByString('A3')).value =
        TextCellValue('Periode: $period  |  Tanggal Cetak: ${_fmtDate(DateTime.now())}');
    summarySheet.cell(CellIndex.indexByString('A3')).cellStyle = CellStyle(
      fontSize: 9,
      fontColorHex: ExcelColor.fromHexString('#475569'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Baris kosong
    summarySheet.cell(CellIndex.indexByString('A4')).value =
        TextCellValue('');

    // Sub-judul Statistik
    summarySheet.merge(
        CellIndex.indexByString('A5'), CellIndex.indexByString('F5'));
    summarySheet.cell(CellIndex.indexByString('A5')).value =
        TextCellValue('RINGKASAN STATISTIK');
    summarySheet.cell(CellIndex.indexByString('A5')).cellStyle =
        subHeaderStyle();

    // Header statistik
    final statHeaders = ['Indikator', 'Jumlah', 'Keterangan'];
    for (int i = 0; i < statHeaders.length; i++) {
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 5))
          .value = TextCellValue(statHeaders[i]);
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 5))
          .cellStyle = headerStyle();
    }

    final stats = [
      ['Total Permohonan', '${requests.length}', 'Semua berkas terdaftar'],
      ['Disetujui & Tuntas', '$completed', 'Status selesai atau disetujui aktif'],
      ['Sedang Diproses / Menunggu', '$pending', 'Belum mendapat keputusan'],
      ['Ditolak', '$rejected', 'Permohonan tidak disetujui'],
      ['Total Armada Pool', '${vehicles.length} Unit', 'Mobil & motor dinas'],
      ['Bidang Teraktif', topDept, 'Unit kerja peminjam terbanyak'],
    ];

    for (int i = 0; i < stats.length; i++) {
      for (int j = 0; j < stats[i].length; j++) {
        summarySheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 6 + i))
            .value = TextCellValue(stats[i][j]);
      }
    }

    // Set column widths
    summarySheet.setColumnWidth(0, 35);
    summarySheet.setColumnWidth(1, 15);
    summarySheet.setColumnWidth(2, 40);

    // ─── SHEET 2: ARMADA ────────────────────────────────────
    final vehicleSheet = excel['Armada Pool'];
    // Judul
    vehicleSheet.merge(
        CellIndex.indexByString('A1'), CellIndex.indexByString('G1'));
    vehicleSheet.cell(CellIndex.indexByString('A1')).value =
        TextCellValue('DATA ARMADA POOL DINAS');
    vehicleSheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
      bold: true,
      fontSize: 12,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#1E3A5F'),
      horizontalAlign: HorizontalAlign.Center,
    );

    final vehicleHeaders = [
      'No.',
      'Nama Kendaraan',
      'No. Polisi',
      'Tipe',
      'Transmisi',
      'Kapasitas',
      'Jml. Penugasan',
    ];
    for (int i = 0; i < vehicleHeaders.length; i++) {
      vehicleSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
          .value = TextCellValue(vehicleHeaders[i]);
      vehicleSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
          .cellStyle = headerStyle();
    }

    for (int i = 0; i < vehicles.length; i++) {
      final v = vehicles[i];
      final loanCnt =
          requests.where((r) => r.vehicleName.contains(v.name)).length;
      final row = [
        '${i + 1}',
        v.name,
        v.plateNumber,
        v.type == VehicleType.mobil ? 'Mobil' : 'Motor',
        v.transmission,
        '${v.capacity} Seat',
        '$loanCnt kali',
      ];
      for (int j = 0; j < row.length; j++) {
        vehicleSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 2 + i))
            .value = TextCellValue(row[j]);
      }
    }

    vehicleSheet.setColumnWidth(0, 5);
    vehicleSheet.setColumnWidth(1, 28);
    vehicleSheet.setColumnWidth(2, 15);
    vehicleSheet.setColumnWidth(3, 10);
    vehicleSheet.setColumnWidth(4, 14);
    vehicleSheet.setColumnWidth(5, 12);
    vehicleSheet.setColumnWidth(6, 16);

    // ─── SHEET 3: DAFTAR PERMOHONAN ─────────────────────────
    final loanSheet = excel['Daftar Permohonan'];

    loanSheet.merge(
        CellIndex.indexByString('A1'), CellIndex.indexByString('I1'));
    loanSheet.cell(CellIndex.indexByString('A1')).value =
        TextCellValue('DAFTAR RIWAYAT PERMOHONAN PEMINJAMAN ARMADA');
    loanSheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
      bold: true,
      fontSize: 12,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#1E3A5F'),
      horizontalAlign: HorizontalAlign.Center,
    );

    final loanHeaders = [
      'No.',
      'Nama Pemohon',
      'Bidang / Unit',
      'Kendaraan',
      'Tujuan Dinas',
      'Mulai',
      'Selesai',
      'No. SPK',
      'Status',
    ];
    for (int i = 0; i < loanHeaders.length; i++) {
      loanSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
          .value = TextCellValue(loanHeaders[i]);
      loanSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
          .cellStyle = headerStyle();
    }

    String statusText(LoanStatus s) {
      switch (s) {
        case LoanStatus.disetujui:
        case LoanStatus.approved:
          return 'Disetujui';
        case LoanStatus.selesai:
          return 'Selesai (BAST)';
        case LoanStatus.ditolak:
        case LoanStatus.rejected:
          return 'Ditolak';
        case LoanStatus.dibatalkan:
          return 'Dibatalkan';
        default:
          return 'Menunggu';
      }
    }

    for (int i = 0; i < requests.length; i++) {
      final r = requests[i];
      final row = [
        '${i + 1}',
        r.borrowerName,
        r.department.isNotEmpty ? r.department : 'Dinsos Jatim',
        r.vehicleName,
        r.destination,
        _fmtDate(r.startDate),
        _fmtDate(r.endDate),
        r.spkNumber ?? '-',
        statusText(r.status),
      ];
      for (int j = 0; j < row.length; j++) {
        loanSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 2 + i))
            .value = TextCellValue(row[j]);
      }
    }

    loanSheet.setColumnWidth(0, 5);
    loanSheet.setColumnWidth(1, 25);
    loanSheet.setColumnWidth(2, 22);
    loanSheet.setColumnWidth(3, 22);
    loanSheet.setColumnWidth(4, 28);
    loanSheet.setColumnWidth(5, 13);
    loanSheet.setColumnWidth(6, 13);
    loanSheet.setColumnWidth(7, 16);
    loanSheet.setColumnWidth(8, 16);

    final bytes = excel.encode();
    if (bytes != null) {
      _downloadFile(
        Uint8List.fromList(bytes),
        'SIPK-LAPORAN-ARMADA-${_periodToFileName(period)}.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }
  }

  // ─── HELPER: DOWNLOAD VIA PLATFORM ─────────────────────────
  static void _downloadFile(
      Uint8List bytes, String filename, String mimeType) {
    saveAndDownloadFile(bytes, filename, mimeType);
  }

  // ─── HELPER: FORMAT TANGGAL ─────────────────────────────────
  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _periodToFileName(String period) =>
      period.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').replaceAll('__', '_');

  // ─── HELPER: PDF WIDGETS ────────────────────────────────────
  static pw.Widget _pdfStatCard(
      String label, String value, String sub, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFF8FAFC),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 7,
                color: PdfColor.fromInt(0xFF1E293B),
              ),
              maxLines: 2,
            ),
            pw.Text(
              sub,
              style: const pw.TextStyle(
                  fontSize: 6, color: PdfColor.fromInt(0xFF94A3B8)),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _pdfTableCell(String text,
      {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 8 : 7.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader
              ? PdfColors.white
              : const PdfColor.fromInt(0xFF1E293B),
        ),
      ),
    );
  }

  static pw.Widget _pdfStatusCell(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      alignment: pw.Alignment.center,
      child: pw.Container(
        padding:
            const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: pw.BoxDecoration(
          color: color.shade(0.85),
          borderRadius:
              const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

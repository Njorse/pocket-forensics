import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:first_app/features/scanner/domain/models/exif_data.dart';
import 'package:first_app/features/scanner/domain/models/hash_result.dart';

/// Service responsible for generating forensic PDF reports.
///
/// Uses the `pdf` package to build the document and `printing`
/// to trigger the platform print/download dialog.
class ReportService {
  /// Generates and shows the print/download dialog for a forensic report.
  Future<void> generateAndPrint({
    required HashResult hashResult,
    required ExifData exifData,
  }) async {
    final pdf = _buildPdf(hashResult: hashResult, exifData: exifData);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'PocketForensics_${hashResult.fileName}',
    );
  }

  /// Builds the full PDF document.
  pw.Document _buildPdf({
    required HashResult hashResult,
    required ExifData exifData,
  }) {
    final pdf = pw.Document(
      title: 'PocketForensics — Reporte Forense',
      author: 'PocketForensics',
    );

    final now = DateFormat('dd/MM/yyyy – HH:mm:ss').format(DateTime.now());
    final displayMap = exifData.toDisplayMap();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(now),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // ── File Info Section ────────────────────────────────
          _sectionTitle('Información del Archivo'),
          _keyValueRow('Nombre', hashResult.fileName),
          _keyValueRow('Tamaño', hashResult.formattedSize),
          _keyValueRow('Tiempo de análisis', hashResult.formattedTime),
          pw.SizedBox(height: 20),

          // ── Hash Section ────────────────────────────────────
          _sectionTitle('Hash de Integridad'),
          _keyValueRow('Algoritmo', hashResult.algorithm),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            margin: const pw.EdgeInsets.only(top: 6, bottom: 6),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#1B1E24'),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              hashResult.hash,
              style: pw.TextStyle(
                font: pw.Font.courier(),
                fontSize: 10,
                color: PdfColor.fromHex('#00FFFF'),
                letterSpacing: 0.5,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // ── EXIF Section ────────────────────────────────────
          _sectionTitle('Metadatos EXIF'),
          if (displayMap.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 12),
              child: pw.Text(
                'No se detectaron metadatos EXIF en este archivo.',
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            )
          else
            _buildExifTable(displayMap),
          pw.SizedBox(height: 24),

          // ── Disclaimer ──────────────────────────────────────
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Este reporte fue generado automáticamente por PocketForensics. '
              'El hash SHA-256 garantiza la integridad del archivo al momento '
              'del análisis. Cualquier modificación posterior alterará el hash.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  // ─── Header ──────────────────────────────────────────────────

  pw.Widget _buildHeader(String dateStr) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PocketForensics',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#101318'),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Reporte de Análisis Forense Digital',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Fecha del análisis',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
              ),
              pw.Text(
                dateStr,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Footer ──────────────────────────────────────────────────

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'PocketForensics — Análisis forense local',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  // ─── Section Title ───────────────────────────────────────────

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#101318'),
        ),
      ),
    );
  }

  // ─── Key-Value Row ───────────────────────────────────────────

  pw.Widget _keyValueRow(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              key,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ─── EXIF Table ──────────────────────────────────────────────

  pw.Widget _buildExifTable(Map<String, String> displayMap) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF272A31),
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
      },
      headers: ['Campo', 'Valor'],
      data: displayMap.entries
          .map((e) => [e.key, e.value])
          .toList(),
    );
  }
}

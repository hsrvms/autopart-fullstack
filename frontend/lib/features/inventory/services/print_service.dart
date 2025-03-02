import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintService {
  static Future<void> printBarcode(Map<String, dynamic> templateData, int templateIndex) async {
    try {
      final pdf = pw.Document();

      // Sayfa boyutunu ayarla (100x50mm barkod etiketi için)
      final pageFormat = PdfPageFormat(
        100 * PdfPageFormat.mm,
        50 * PdfPageFormat.mm,
        marginAll: 5 * PdfPageFormat.mm,
      );

      // PDF sayfası oluştur
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Barkod
              pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: templateData['barcode'] ?? '',
                width: 80 * PdfPageFormat.mm,
                height: 15 * PdfPageFormat.mm,
              ),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),

              // Barkod numarası
              pw.Text(
                templateData['barcode'] ?? '',
                style: pw.TextStyle(fontSize: 8),
              ),

              // Araç bilgileri
              pw.Text(
                '${templateData['make']} ${templateData['model']} ${templateData['submodel'] ?? ''}',
                style: pw.TextStyle(fontSize: 8),
              ),

              // Parça bilgileri
              pw.Text(
                '${templateData['partNumber']} - ${templateData['category']}',
                style: pw.TextStyle(fontSize: 8),
              ),

              // Stok bilgileri
              pw.Text(
                'Stok: ${templateData['stock']} / Min: ${templateData['minStock']}',
                style: pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
      );

      // PDF'i yazdır
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Barkod - ${templateData['barcode']}.pdf',
      );
    } catch (e) {
      print('Yazdırma hatası: $e');
      rethrow;
    }
  }
}

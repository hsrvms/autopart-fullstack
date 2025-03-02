import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintService {
  static Future<void> printBarcode(Map<String, dynamic> templateData, int templateIndex) async {
    try {
      final pdf = pw.Document();
      final pageFormat = PdfPageFormat(
        100 * PdfPageFormat.mm,
        50 * PdfPageFormat.mm,
        marginAll: 5 * PdfPageFormat.mm,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (context) {
            switch (templateIndex) {
              case 0: // Sadece barkod
                return _buildBasicTemplate(templateData);
              case 1: // Barkod ve temel bilgiler
                return _buildBasicInfoTemplate(templateData);
              case 2: // Barkod ve araç bilgileri
                return _buildVehicleInfoTemplate(templateData);
              case 3: // Barkod ve stok bilgileri
                return _buildStockInfoTemplate(templateData);
              case 4: // Tüm detaylar
                return _buildFullDetailsTemplate(templateData);
              default:
                return _buildBasicTemplate(templateData);
            }
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Barkod - ${templateData['barcode']}.pdf',
      );
    } catch (e) {
      print('Yazdırma hatası: $e');
      rethrow;
    }
  }

  static pw.Widget _buildBasicTemplate(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.code128(),
          data: data['barcode'] ?? '',
          width: 80 * PdfPageFormat.mm,
          height: 15 * PdfPageFormat.mm,
        ),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        pw.Text(
          data['barcode'] ?? '',
          style: pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  static pw.Widget _buildBasicInfoTemplate(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.code128(),
          data: data['barcode'] ?? '',
          width: 80 * PdfPageFormat.mm,
          height: 15 * PdfPageFormat.mm,
        ),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        pw.Text(
          data['barcode'] ?? '',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Parça No: ${data['partNumber']}',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Kategori: ${data['category']}',
          style: pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  static pw.Widget _buildVehicleInfoTemplate(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.code128(),
          data: data['barcode'] ?? '',
          width: 80 * PdfPageFormat.mm,
          height: 15 * PdfPageFormat.mm,
        ),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        pw.Text(
          data['barcode'] ?? '',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          '${data['make']} ${data['model']} ${data['submodel']}',
          style: pw.TextStyle(fontSize: 8),
        ),
        if (data['yearRange']?.isNotEmpty ?? false)
          pw.Text(
            'Yıl: ${data['yearRange']}',
            style: pw.TextStyle(fontSize: 8),
          ),
      ],
    );
  }

  static pw.Widget _buildStockInfoTemplate(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.code128(),
          data: data['barcode'] ?? '',
          width: 80 * PdfPageFormat.mm,
          height: 15 * PdfPageFormat.mm,
        ),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        pw.Text(
          data['barcode'] ?? '',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Parça No: ${data['partNumber']}',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Stok: ${data['stock']} / Min: ${data['minStock']}',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Konum: ${data['location']}',
          style: pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  static pw.Widget _buildFullDetailsTemplate(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.code128(),
          data: data['barcode'] ?? '',
          width: 80 * PdfPageFormat.mm,
          height: 15 * PdfPageFormat.mm,
        ),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        pw.Text(
          data['barcode'] ?? '',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          '${data['make']} ${data['model']} ${data['submodel']}',
          style: pw.TextStyle(fontSize: 8),
        ),
        if (data['yearRange']?.isNotEmpty ?? false)
          pw.Text(
            'Yıl: ${data['yearRange']}',
            style: pw.TextStyle(fontSize: 8),
          ),
        pw.Text(
          'Parça No: ${data['partNumber']} (${data['category']})',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Stok: ${data['stock']} / Min: ${data['minStock']}',
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Konum: ${data['location']}',
          style: pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }
}

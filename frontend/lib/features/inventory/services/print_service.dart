import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintService {
  static Future<void> printBarcode(Map<String, dynamic> templateData, int templateIndex) async {
    try {
      // Roboto fontunu yükle
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      final pdf = pw.Document();
      final pageFormat = PdfPageFormat(
        100 * PdfPageFormat.mm,
        100 * PdfPageFormat.mm,
        marginAll: 5 * PdfPageFormat.mm,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          theme: pw.ThemeData.withFont(
            base: ttf,
          ),
          build: (context) {
            switch (templateIndex) {
              case 0: // Sadece barkod
                return _buildBasicTemplate(templateData, ttf);
              case 1: // Barkod ve temel bilgiler
                return _buildBasicInfoTemplate(templateData, ttf);
              case 2: // Barkod ve araç bilgileri
                return _buildVehicleInfoTemplate(templateData, ttf);
              case 3: // Barkod ve stok bilgileri
                return _buildStockInfoTemplate(templateData, ttf);
              case 4: // Tüm detaylar
                return _buildFullDetailsTemplate(templateData, ttf);
              default:
                return _buildBasicTemplate(templateData, ttf);
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

  static pw.Widget _buildBasicTemplate(Map<String, dynamic> data, pw.Font font) {
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
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildBasicInfoTemplate(Map<String, dynamic> data, pw.Font font) {
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
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          '${data['make']} ${data['model']} ${data['submodel']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          'Yıl: ${data['yearRange']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildVehicleInfoTemplate(Map<String, dynamic> data, pw.Font font) {
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
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          '${data['make']} ${data['model']} ${data['submodel']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          'Yıl: ${data['yearRange']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          'OEM: ${data['oem']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          'Açıklama: ${data['description']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildStockInfoTemplate(Map<String, dynamic> data, pw.Font font) {
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
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          'Kategori: ${data['category']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          'Parça No: ${data['partNumber']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          'OEM: ${data['oem']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          'Açıklama: ${data['description']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          'Stok: ${data['stock']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          'Min. Stok: ${data['minStock']}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildFullDetailsTemplate(Map<String, dynamic> data, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.code128(),
          data: data['barcode'] ?? '',
          width: 90 * PdfPageFormat.mm,
          height: 20 * PdfPageFormat.mm,
        ),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        pw.Text(
          data['barcode'] ?? '',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        pw.Text(
          '${data['make']} ${data['model']} ${data['submodel']}',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.Text(
          'Yıl: ${data['yearRange']}',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.Text(
          'Kategori: ${data['category']}',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.Text(
          'Parça No: ${data['partNumber']}',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.Text(
          'OEM: ${data['oem']}',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.Text(
          'Açıklama: ${data['description']}',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.Text(
          'Stok: ${data['stock']}',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.Text(
          'Min. Stok: ${data['minStock']}',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.Text(
          'Konum: ${data['location']}',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
      ],
    );
  }
}

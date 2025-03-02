import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/barcode_template.dart';

class BarcodePrintService {
  Future<pw.Font> _loadFont() async {
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  Future<void> printBarcode(
    String barcode,
    Map<String, String> vehicleInfo,
    Map<String, dynamic> partInfo,
    BarcodeTemplate template,
    int copies,
  ) async {
    print('Yazdırılıyor...');
    print('Şablon: ${template.name}');
    print('Barkod: $barcode');
    print('Kopya sayısı: $copies');

    try {
      final font = await _loadFont();
      final pdf = pw.Document();

      final pageFormat = PdfPageFormat(
        105 * PdfPageFormat.mm,
        148 * PdfPageFormat.mm,
        marginAll: 5 * PdfPageFormat.mm,
      );

      final theme = pw.ThemeData.withFont(
        base: font,
      );

      for (var i = 0; i < copies; i++) {
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            theme: theme,
            build: (context) => _buildTemplate(
              template,
              barcode,
              vehicleInfo,
              partInfo,
            ),
          ),
        );
      }

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Barkod - $barcode.pdf',
      );

      print('PDF oluşturma başarılı');
    } catch (e, stackTrace) {
      print('Yazdırma hatası: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  pw.Widget _buildTemplate(
    BarcodeTemplate template,
    String barcode,
    Map<String, String> vehicleInfo,
    Map<String, dynamic> partInfo,
  ) {
    switch (template.type) {
      case BarcodeTemplateType.barcodeOnly:
      case BarcodeTemplateType.barcodeWithText:
      case BarcodeTemplateType.barcodeWithDetails:
        return _buildBarcodeWithDetails(barcode, vehicleInfo, partInfo);
      case BarcodeTemplateType.compactLabel:
        return _buildCompactLabel(barcode, vehicleInfo, partInfo);
      case BarcodeTemplateType.fullLabel:
        return _buildFullLabel(barcode, vehicleInfo, partInfo);
    }
  }

  pw.Widget _buildBarcodeWithDetails(
    String barcode,
    Map<String, String> vehicleInfo,
    Map<String, dynamic> partInfo,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.BarcodeWidget(
          data: barcode,
          width: 200,
          height: 80,
          barcode: pw.Barcode.code128(),
        ),
        pw.SizedBox(height: 10),
        pw.Text(barcode),
        pw.SizedBox(height: 10),
        pw.Text('${vehicleInfo['make']} ${vehicleInfo['model']}'),
        if (vehicleInfo['submodel']?.isNotEmpty ?? false) pw.Text(vehicleInfo['submodel']!),
        pw.Text('Yıl: ${vehicleInfo['year']}'),
      ],
    );
  }

  pw.Widget _buildCompactLabel(
    String barcode,
    Map<String, String> vehicleInfo,
    Map<String, dynamic> partInfo,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.BarcodeWidget(
          data: barcode,
          width: 200,
          height: 80,
          barcode: pw.Barcode.code128(),
        ),
        pw.SizedBox(height: 5),
        pw.Text(barcode),
        pw.SizedBox(height: 5),
        pw.Text('${vehicleInfo['make']} ${vehicleInfo['model']}'),
        if (vehicleInfo['submodel']?.isNotEmpty ?? false) pw.Text(vehicleInfo['submodel']!),
        pw.Text('${partInfo['name']} - ${partInfo['category']}'),
      ],
    );
  }

  pw.Widget _buildFullLabel(
    String barcode,
    Map<String, String> vehicleInfo,
    Map<String, dynamic> partInfo,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.BarcodeWidget(
          data: barcode,
          width: 200,
          height: 80,
          barcode: pw.Barcode.code128(),
        ),
        pw.SizedBox(height: 5),
        pw.Text(barcode),
        pw.SizedBox(height: 5),
        pw.Text('${vehicleInfo['make']} ${vehicleInfo['model']}'),
        if (vehicleInfo['submodel']?.isNotEmpty ?? false) pw.Text(vehicleInfo['submodel']!),
        pw.Text('Yıl: ${vehicleInfo['year']}'),
        pw.SizedBox(height: 5),
        pw.Text('${partInfo['name']} - ${partInfo['category']}'),
        pw.Text('Stok: ${partInfo['current_stock']} / Min: ${partInfo['minimum_stock']}'),
        pw.Text('Fiyat: ${partInfo['sell_price']} TL'),
      ],
    );
  }
}

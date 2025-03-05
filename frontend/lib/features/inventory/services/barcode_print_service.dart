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
        template.paperSize.widthInPoints,
        template.paperSize.heightInPoints,
        marginAll: 2 * PdfPageFormat.mm,
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
              pageFormat,
            ),
          ),
        );
      }

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: 'Barkod - $barcode.pdf',
        format: pageFormat,
        usePrinterSettings: true,
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
    PdfPageFormat pageFormat,
  ) {
    final barcodeWidth = pageFormat.availableWidth * 0.9;
    final barcodeHeight = pageFormat.availableHeight * 0.3;

    switch (template.type) {
      case BarcodeTemplateType.barcodeOnly:
        return _buildBasicTemplate(barcode, barcodeWidth, barcodeHeight);
      case BarcodeTemplateType.barcodeWithText:
        return _buildBasicInfoTemplate(barcode, vehicleInfo, barcodeWidth, barcodeHeight);
      case BarcodeTemplateType.barcodeWithDetails:
        return _buildVehicleInfoTemplate(barcode, vehicleInfo, partInfo, barcodeWidth, barcodeHeight);
      case BarcodeTemplateType.compactLabel:
        return _buildCompactTemplate(barcode, vehicleInfo, partInfo, barcodeWidth, barcodeHeight);
      case BarcodeTemplateType.fullLabel:
        return _buildFullTemplate(barcode, vehicleInfo, partInfo, barcodeWidth, barcodeHeight);
    }
  }

  pw.Widget _buildBasicTemplate(String barcode, double width, double height) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.BarcodeWidget(
            barcode: pw.Barcode.code128(),
            data: barcode,
            width: width,
            height: height,
          ),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Text(
            barcode,
            style: pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBasicInfoTemplate(
    String barcode,
    Map<String, String> vehicleInfo,
    double width,
    double height,
  ) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.BarcodeWidget(
            barcode: pw.Barcode.code128(),
            data: barcode,
            width: width,
            height: height,
          ),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Text(
            barcode,
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            '${vehicleInfo['make']} ${vehicleInfo['model']}',
            style: pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildVehicleInfoTemplate(
    String barcode,
    Map<String, String> vehicleInfo,
    Map<String, dynamic> partInfo,
    double width,
    double height,
  ) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.BarcodeWidget(
            barcode: pw.Barcode.code128(),
            data: barcode,
            width: width,
            height: height,
          ),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Text(
            barcode,
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            '${vehicleInfo['make']} ${vehicleInfo['model']} ${vehicleInfo['submodel']}',
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Yıl: ${vehicleInfo['year']}',
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Parça No: ${partInfo['part_number']}',
            style: pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCompactTemplate(
    String barcode,
    Map<String, String> vehicleInfo,
    Map<String, dynamic> partInfo,
    double width,
    double height,
  ) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.BarcodeWidget(
            barcode: pw.Barcode.code128(),
            data: barcode,
            width: width,
            height: height,
          ),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Text(
            barcode,
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            '${vehicleInfo['make']} ${vehicleInfo['model']} ${vehicleInfo['submodel']}',
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Parça No: ${partInfo['part_number']}',
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Stok: ${partInfo['current_stock']}',
            style: pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFullTemplate(
    String barcode,
    Map<String, String> vehicleInfo,
    Map<String, dynamic> partInfo,
    double width,
    double height,
  ) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.BarcodeWidget(
            barcode: pw.Barcode.code128(),
            data: barcode,
            width: width,
            height: height,
          ),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Text(
            barcode,
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            '${vehicleInfo['make']} ${vehicleInfo['model']} ${vehicleInfo['submodel']}',
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Yıl: ${vehicleInfo['year']}',
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Parça No: ${partInfo['part_number']}',
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Kategori: ${partInfo['category']}',
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Stok: ${partInfo['current_stock']} / Min: ${partInfo['minimum_stock']}',
            style: pw.TextStyle(fontSize: 8),
          ),
          if (partInfo['location'] != null)
            pw.Text(
              'Konum: ${partInfo['location']}',
              style: pw.TextStyle(fontSize: 8),
            ),
        ],
      ),
    );
  }
}

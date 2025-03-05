import 'package:flutter/material.dart';

enum BarcodeTemplateType {
  barcodeOnly, // Sadece barkod
  barcodeWithText, // Barkod ve barkod numarası
  barcodeWithDetails, // Barkod ve araç detayları
  compactLabel, // Küçük etiket (barkod + temel bilgiler)
  fullLabel // Tam etiket (tüm detaylar)
}

enum PaperSize {
  a4(width: 210, height: 297),
  label30x50(width: 30, height: 50),
  label50x30(width: 50, height: 30),
  label100x100(width: 100, height: 100),
  label100x150(width: 100, height: 150);

  final double width; // mm cinsinden genişlik
  final double height; // mm cinsinden yükseklik

  const PaperSize({required this.width, required this.height});

  // mm'yi point'e çevir (1 mm = 2.83465 point)
  double get widthInPoints => width * 2.83465;
  double get heightInPoints => height * 2.83465;
}

class BarcodeTemplate {
  final String name;
  final String description;
  final String previewImage;
  final List<String> fields;
  final BarcodeTemplateType type;
  final PaperSize paperSize;

  const BarcodeTemplate({
    required this.name,
    required this.description,
    required this.previewImage,
    required this.fields,
    required this.type,
    this.paperSize = PaperSize.a4,
  });

  static List<BarcodeTemplate> get templates => [
        BarcodeTemplate(
          name: 'Küçük Etiket (30x50)',
          description: 'Sadece barkod ve kod numarası',
          previewImage: '',
          fields: [],
          type: BarcodeTemplateType.barcodeOnly,
          paperSize: PaperSize.label30x50,
        ),
        BarcodeTemplate(
          name: 'Orta Boy Etiket (50x30)',
          description: 'Barkod ve temel bilgiler',
          previewImage: '',
          fields: [],
          type: BarcodeTemplateType.barcodeWithText,
          paperSize: PaperSize.label50x30,
        ),
        BarcodeTemplate(
          name: 'Büyük Etiket (100x100)',
          description: 'Barkod ve tüm detaylar',
          previewImage: '',
          fields: [],
          type: BarcodeTemplateType.barcodeWithDetails,
          paperSize: PaperSize.label100x100,
        ),
        BarcodeTemplate(
          name: 'Geniş Etiket (100x150)',
          description: 'Tüm bilgiler ve stok detayları',
          previewImage: '',
          fields: [],
          type: BarcodeTemplateType.fullLabel,
          paperSize: PaperSize.label100x150,
        ),
      ];
}

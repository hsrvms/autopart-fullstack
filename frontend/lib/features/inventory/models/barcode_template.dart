import 'package:flutter/material.dart';

enum BarcodeTemplateType {
  barcodeOnly, // Sadece barkod
  barcodeWithText, // Barkod ve barkod numarası
  barcodeWithDetails, // Barkod ve araç detayları
  compactLabel, // Küçük etiket (barkod + temel bilgiler)
  fullLabel // Tam etiket (tüm detaylar)
}

class BarcodeTemplate {
  final String name;
  final String description;
  final String previewImage;
  final List<String> fields;
  final BarcodeTemplateType type;
  final Size size;

  const BarcodeTemplate({
    required this.name,
    required this.description,
    required this.previewImage,
    required this.fields,
    required this.type,
    this.size = const Size(300, 200), // Varsayılan boyut
  });

  static List<BarcodeTemplate> get templates => [
        BarcodeTemplate(
          name: 'Sadece Barkod',
          description: 'Yalnızca barkod görüntüsünü içerir',
          previewImage: '',
          fields: [],
          type: BarcodeTemplateType.barcodeOnly,
          size: const Size(300, 150),
        ),
        BarcodeTemplate(
          name: 'Barkod ve Metin',
          description: 'Barkod görüntüsü ve barkod numarasını içerir',
          previewImage: '',
          fields: [],
          type: BarcodeTemplateType.barcodeWithText,
          size: const Size(300, 200),
        ),
        BarcodeTemplate(
          name: 'Barkod ve Araç Bilgisi',
          description: 'Barkod, numara ve araç detaylarını içerir',
          previewImage: '',
          fields: [],
          type: BarcodeTemplateType.barcodeWithDetails,
          size: const Size(300, 250),
        ),
        BarcodeTemplate(
          name: 'Kompakt Etiket',
          description: 'Barkod, numara, araç bilgisi ve parça numarasını içerir',
          previewImage: '',
          fields: [],
          type: BarcodeTemplateType.compactLabel,
          size: const Size(300, 300),
        ),
        BarcodeTemplate(
          name: 'Tam Etiket',
          description: 'Tüm bilgileri içeren detaylı etiket',
          previewImage: '',
          fields: [],
          type: BarcodeTemplateType.fullLabel,
          size: const Size(300, 400),
        ),
      ];
}

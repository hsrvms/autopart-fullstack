import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/barcode_template.dart';

class BarcodeTemplatePreview extends StatelessWidget {
  final BarcodeTemplate template;
  final String barcode;
  final Uint8List barcodeImage;
  final Map<String, dynamic> vehicleInfo;
  final Map<String, dynamic>? partInfo;

  const BarcodeTemplatePreview({
    Key? key,
    required this.template,
    required this.barcode,
    required this.barcodeImage,
    required this.vehicleInfo,
    this.partInfo,
  }) : super(key: key);

  // mm'yi piksel'e çevirmek için (1mm = ~3.7795275591 piksel)
  double _mmToPixels(double mm) => mm * 3.7795275591;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: _mmToPixels(template.paperSize.width),
        height: _mmToPixels(template.paperSize.height),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildTemplate(),
      ),
    );
  }

  Widget _buildTemplate() {
    switch (template.type) {
      case BarcodeTemplateType.barcodeOnly:
        return _buildBarcodeOnly();
      case BarcodeTemplateType.barcodeWithText:
        return _buildBarcodeWithText();
      case BarcodeTemplateType.barcodeWithDetails:
        return _buildBarcodeWithDetails();
      case BarcodeTemplateType.compactLabel:
        return _buildCompactLabel();
      case BarcodeTemplateType.fullLabel:
        return _buildFullLabel();
    }
  }

  Widget _buildBarcodeOnly() {
    return Center(
      child: Image.memory(
        barcodeImage,
        width: 200,
        height: 100,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildBarcodeWithText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.memory(
              barcodeImage,
              width: 180,
              height: 90,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Text(
              barcode,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeWithDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.memory(
              barcodeImage,
              width: 180,
              height: 90,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Text(
              barcode,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            if (vehicleInfo['submodel'] != null && vehicleInfo['submodel']!.isNotEmpty)
              Text(
                '${vehicleInfo['make']} ${vehicleInfo['model']} ${vehicleInfo['submodel']} ${vehicleInfo['year']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              )
            else
              Text(
                '${vehicleInfo['make']} ${vehicleInfo['model']} ${vehicleInfo['year']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLabel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.memory(
              barcodeImage,
              width: 180,
              height: 90,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Text(
              barcode,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            if (vehicleInfo['submodel'] != null && vehicleInfo['submodel']!.isNotEmpty)
              Text(
                '${vehicleInfo['make']} ${vehicleInfo['model']} ${vehicleInfo['submodel']} ${vehicleInfo['year']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              )
            else
              Text(
                '${vehicleInfo['make']} ${vehicleInfo['model']} ${vehicleInfo['year']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            if (partInfo != null) ...[
              const SizedBox(height: 2),
              Text(
                'Parça No: ${partInfo!['part_number']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullLabel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.memory(
              barcodeImage,
              width: 180,
              height: 90,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Text(
              barcode,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            if (vehicleInfo['submodel'] != null && vehicleInfo['submodel']!.isNotEmpty)
              Text(
                '${vehicleInfo['make']} ${vehicleInfo['model']} ${vehicleInfo['submodel']} ${vehicleInfo['year']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              )
            else
              Text(
                '${vehicleInfo['make']} ${vehicleInfo['model']} ${vehicleInfo['year']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            if (partInfo != null) ...[
              const SizedBox(height: 2),
              Text(
                'Parça No: ${partInfo!['part_number']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'Parça Adı: ${partInfo!['name']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (partInfo!['category'] != null && partInfo!['category']!.isNotEmpty)
                Text(
                  'Kategori: ${partInfo!['category']}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

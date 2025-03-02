import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/barcode_template.dart';
import '../services/barcode_print_service.dart';

class BarcodePrintDialog extends StatefulWidget {
  final String barcode;
  final Uint8List barcodeImage;
  final Map<String, String> vehicleInfo;
  final Map<String, dynamic> partInfo;

  const BarcodePrintDialog({
    Key? key,
    required this.barcode,
    required this.barcodeImage,
    required this.vehicleInfo,
    required this.partInfo,
  }) : super(key: key);

  @override
  State<BarcodePrintDialog> createState() => _BarcodePrintDialogState();
}

class _BarcodePrintDialogState extends State<BarcodePrintDialog> {
  final _printService = BarcodePrintService();
  int _selectedTemplate = 0;
  final List<BarcodeTemplate> _templates = [
    BarcodeTemplate(
      name: 'Standart',
      description: 'Temel bilgilerle basit barkod etiketi',
      previewImage: '',
      fields: ['barcode', 'part_number', 'name'],
      type: BarcodeTemplateType.barcodeWithText,
    ),
    BarcodeTemplate(
      name: 'Detaylı',
      description: 'Tüm parça detaylarıyla geniş etiket',
      previewImage: '',
      fields: ['barcode', 'part_number', 'name', 'description', 'category', 'vehicle_info'],
      type: BarcodeTemplateType.fullLabel,
    ),
    BarcodeTemplate(
      name: 'Fiyatlı',
      description: 'Satış fiyatı ile birlikte kompakt etiket',
      previewImage: '',
      fields: ['barcode', 'part_number', 'name', 'sell_price'],
      type: BarcodeTemplateType.compactLabel,
    ),
    BarcodeTemplate(
      name: 'Stok Bilgili',
      description: 'Stok bilgileri ile birlikte etiket',
      previewImage: '',
      fields: ['barcode', 'part_number', 'name', 'current_stock', 'minimum_stock'],
      type: BarcodeTemplateType.compactLabel,
    ),
    BarcodeTemplate(
      name: 'Araç Detaylı',
      description: 'Araç bilgileri ile birlikte geniş etiket',
      previewImage: '',
      fields: ['barcode', 'part_number', 'name', 'vehicle_info'],
      type: BarcodeTemplateType.barcodeWithDetails,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Barkod Yazdırma Şablonu Seçin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final template = _templates[index];
                  return Card(
                    elevation: _selectedTemplate == index ? 4 : 1,
                    color: _selectedTemplate == index ? Colors.blue.shade50 : null,
                    child: InkWell(
                      onTap: () => setState(() => _selectedTemplate = index),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: _selectedTemplate,
                              onChanged: (value) {
                                setState(() => _selectedTemplate = value!);
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    template.description,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: template.fields.map((field) {
                                      return Chip(
                                        label: Text(field),
                                        backgroundColor: Colors.blue.shade100,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final selectedTemplate = _templates[_selectedTemplate];
                    print(selectedTemplate);
                    print(widget.barcode);
                    print(widget.barcodeImage);
                    print(widget.vehicleInfo);
                    print(widget.partInfo);
                    await _printService.printBarcode(
                      widget.barcode,
                      widget.vehicleInfo,
                      widget.partInfo,
                      selectedTemplate,
                      1,
                    );
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Yazdır'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

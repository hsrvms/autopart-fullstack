import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
    receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
    headers: AppConfig.headers,
  ));

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      print('Stok listesi yükleniyor...');
      final response = await _dio.get('/items');
      print('Stok API yanıtı: ${response.data}');

      if (response.statusCode == 200) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(response.data);
          _isLoading = false;
        });
      } else {
        print('Stok listesi yüklenirken hata: ${response.statusCode} - ${response.data}');
        _showError('Stok listesi yüklenirken bir hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Stok listesi yüklenirken hata: $e');
      _showError('Stok listesi yüklenirken bir hata oluştu');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Listesi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/inventory/add'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Parça No')),
                    DataColumn(label: Text('Açıklama')),
                    DataColumn(label: Text('Kategori')),
                    DataColumn(label: Text('Marka')),
                    DataColumn(label: Text('Model')),
                    DataColumn(label: Text('Alt Model')),
                    DataColumn(label: Text('OEM No')),
                    DataColumn(label: Text('Stok')),
                    DataColumn(label: Text('Min. Stok')),
                    DataColumn(label: Text('Alış Fiyatı')),
                    DataColumn(label: Text('Satış Fiyatı')),
                    DataColumn(label: Text('Tedarikçi')),
                    DataColumn(label: Text('Konum')),
                    DataColumn(label: Text('Ağırlık')),
                    DataColumn(label: Text('Boyutlar')),
                    DataColumn(label: Text('Garanti')),
                  ],
                  rows: _items
                      .map((item) => DataRow(
                            cells: [
                              DataCell(Text(item['part_number'] ?? '')),
                              DataCell(Text(item['description'] ?? '')),
                              DataCell(Text(item['category_name'] ?? '')),
                              DataCell(Text(item['make_name'] ?? '')),
                              DataCell(Text(item['model_name'] ?? '')),
                              DataCell(Text(item['submodel_name'] ?? '')),
                              DataCell(Text(item['oem_number'] ?? '-')),
                              DataCell(Text(item['current_stock']?.toString() ?? '-')),
                              DataCell(Text(item['minimum_stock']?.toString() ?? '-')),
                              DataCell(Text(item['buy_price'] != null ? '₺${item['buy_price']}' : '-')),
                              DataCell(Text(item['sell_price'] != null ? '₺${item['sell_price']}' : '-')),
                              DataCell(Text(item['supplier_name'] ?? '-')),
                              DataCell(Text(() {
                                final List<String> location = [];
                                if (item['location_aisle'] != null) location.add(item['location_aisle']);
                                if (item['location_shelf'] != null) location.add(item['location_shelf']);
                                if (item['location_bin'] != null) location.add(item['location_bin']);
                                return location.isEmpty ? '-' : location.join(' / ');
                              }())),
                              DataCell(Text(item['weight_kg']?.toString() ?? '-')),
                              DataCell(Text(item['dimensions_cm'] ?? '-')),
                              DataCell(Text(item['warranty_period'] ?? '-')),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
    );
  }
}

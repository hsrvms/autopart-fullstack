import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/repositories/part_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../services/print_service.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _searchController = TextEditingController();
  final _partRepository = GetIt.instance<PartRepository>();
  Timer? _debounce;
  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];
  final _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
    receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
    headers: AppConfig.headers,
  ));
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get(AppConfig.itemsEndpoint);
      if (response.statusCode == 200) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(response.data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Parçalar yüklenirken bir hata oluştu';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Parçalar yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchItems(String query) async {
    if (query.isEmpty) {
      _loadItems();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final items = await _partRepository.searchParts(query);
      setState(() => _items = List<Map<String, dynamic>>.from(items));
    } catch (e) {
      _showError('Arama yapılırken bir hata oluştu');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isEmpty) {
        _loadItems();
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        _dio.get(AppConfig.searchEndpoint, queryParameters: {
          'search': value,
        }).then((response) {
          if (response.statusCode == 200) {
            setState(() {
              _items = List<Map<String, dynamic>>.from(response.data);
              _isLoading = false;
            });
          } else {
            setState(() {
              _errorMessage = 'Arama yapılırken bir hata oluştu';
              _isLoading = false;
            });
          }
        }).catchError((error) {
          setState(() {
            _errorMessage = 'Arama yapılırken bir hata oluştu: $error';
            _isLoading = false;
          });
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Arama yapılırken bir hata oluştu: $e';
          _isLoading = false;
        });
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _showBarcodeDialog(Map<String, dynamic> item) async {
    int _selectedTemplateIndex = 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Barkod Şablonları',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 400,
                  child: StatefulBuilder(
                    builder: (context, setState) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(5, (index) {
                          final isSelected = _selectedTemplateIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedTemplateIndex = index;
                                });
                              },
                              child: Container(
                                width: 300,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Şablon ${index + 1}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    BarcodeWidget(
                                      barcode: Barcode.code128(),
                                      data: item['barcode'] ?? item['part_number'],
                                      width: 250,
                                      height: 100,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['barcode'] ?? item['part_number'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                      ),
                                    ),
                                    if (index >= 1) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Araç: ${item['make_name'] ?? ""} ${item['model_name'] ?? ""} ${item['submodel_name'] ?? ""}',
                                        style: TextStyle(
                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Yıl: ${item['year_from'] != null ? item['year_to'] != null && item['year_from'] != item['year_to'] ? "${item['year_from']}-${item['year_to']}" : "${item['year_from']}" : ""}',
                                        style: TextStyle(
                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                        ),
                                      ),
                                    ],
                                    if (index >= 2) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'OEM: ${item['oem_code'] ?? ""}',
                                        style: TextStyle(
                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Açıklama: ${item['description'] ?? ""}',
                                        style: TextStyle(
                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                        ),
                                      ),
                                    ],
                                    if (index >= 3) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Kategori: ${item['category_name'] ?? ""}',
                                        style: TextStyle(
                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Parça No: ${item['part_number'] ?? ""}',
                                        style: TextStyle(
                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                        ),
                                      ),
                                    ],
                                    if (index >= 4) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Stok: ${item['current_stock'] ?? ""}',
                                        style: TextStyle(
                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Raf: ${item['location_aisle'] ?? ""}-${item['location_shelf'] ?? ""}-${item['location_bin'] ?? ""}',
                                        style: TextStyle(
                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final templateData = {
                            'barcode': item['barcode'] ?? item['part_number'],
                            'make': item['make_name'] ?? '',
                            'model': item['model_name'] ?? '',
                            'submodel': item['submodel_name'] ?? '',
                            'yearRange': item['year_from'] != null
                                ? item['year_to'] != null && item['year_from'] != item['year_to']
                                    ? '${item['year_from']}-${item['year_to']}'
                                    : '${item['year_from']}'
                                : '',
                            'partNumber': item['part_number'] ?? '',
                            'category': item['category_name'] ?? '',
                            'oem': item['oem_code'] ?? '',
                            'description': item['description'] ?? '',
                            'stock': item['current_stock']?.toString() ?? '',
                            'minStock': item['minimum_stock']?.toString() ?? '',
                            'location':
                                '${item['location_aisle'] ?? ''}-${item['location_shelf'] ?? ''}-${item['location_bin'] ?? ''}',
                          };

                          await PrintService.printBarcode(templateData, _selectedTemplateIndex);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Yazdırma işlemi başarıyla tamamlandı'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Yazdırma hatası: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Yazdır'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Kapat'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Parça no, açıklama veya OEM kodu ile ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Parça No')),
                            DataColumn(label: Text('Açıklama')),
                            DataColumn(label: Text('Kategori')),
                            DataColumn(label: Text('Marka')),
                            DataColumn(label: Text('Model')),
                            DataColumn(label: Text('Alt Model')),
                            DataColumn(label: Text('Yıl Aralığı')),
                            DataColumn(label: Text('Stok')),
                            DataColumn(label: Text('Min. Stok')),
                            DataColumn(label: Text('Satış Fiyatı')),
                            DataColumn(label: Text('İşlemler')),
                          ],
                          rows: _items.map((item) {
                            String yearRange = '';
                            if (item['year_from'] != null) {
                              if (item['year_to'] != null && item['year_from'] != item['year_to']) {
                                yearRange = '${item['year_from']}-${item['year_to']}';
                              } else {
                                yearRange = '${item['year_from']}';
                              }
                            }

                            return DataRow(
                              cells: [
                                DataCell(Text(item['part_number'] ?? '')),
                                DataCell(Text(item['description'] ?? '')),
                                DataCell(Text(item['category_name'] ?? '')),
                                DataCell(Text(item['make_name'] ?? '')),
                                DataCell(Text(item['model_name'] ?? '')),
                                DataCell(Text(item['submodel_name'] ?? '')),
                                DataCell(Text(yearRange)),
                                DataCell(Text('${item['current_stock']}')),
                                DataCell(Text('${item['minimum_stock']}')),
                                DataCell(Text('${item['sell_price']} TL')),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (item['barcode'] != null)
                                        IconButton(
                                          icon: const Icon(Icons.qr_code),
                                          onPressed: () => _showBarcodeDialog(item),
                                          tooltip: 'Barkodu Göster',
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => context.go('/add-part', extra: item),
                                        tooltip: 'Düzenle',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-part'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

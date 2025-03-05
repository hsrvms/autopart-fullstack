import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../vehicles/data/models/make_model.dart';
import '../../../vehicles/data/models/model_model.dart';
import '../../../vehicles/data/models/submodel_model.dart';
import '../../../vehicles/data/repositories/make_repository.dart';
import '../../../vehicles/data/repositories/model_repository.dart';
import '../../../vehicles/data/repositories/submodel_repository.dart';
import '../../data/repositories/part_repository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barcode_widget/barcode_widget.dart';
import '../../data/repositories/category_repository.dart';
import 'dart:async';
import 'dart:typed_data';
import '../../models/barcode_template.dart';
import '../../widgets/barcode_template_preview.dart';
import '../../widgets/barcode_print_dialog.dart';
import '../../services/barcode_print_service.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../services/print_service.dart';
import '../../../../core/config/app_config.dart';

class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _formKey = GlobalKey<FormState>();
  final _makeRepository = GetIt.instance<MakeRepository>();
  final _modelRepository = GetIt.instance<ModelRepository>();
  final _subModelRepository = GetIt.instance<SubModelRepository>();
  final _partRepository = GetIt.instance<PartRepository>();
  final _categoryRepository = GetIt.instance<CategoryRepository>();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
    receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
    headers: AppConfig.headers,
  ));

  // Controller'ları ekleyelim
  final _partSearchController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _searchController = TextEditingController();
  final _partNameController = TextEditingController();
  final _oemNumberController = TextEditingController();
  final _locationAisleController = TextEditingController();
  final _locationShelfController = TextEditingController();
  final _locationBinController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _warrantyPeriodController = TextEditingController();
  final _yearFromController = TextEditingController();
  final _yearToController = TextEditingController();
  bool _isActive = true;

  bool _isLoading = false;
  bool _isSearching = false;
  Timer? _debounce;
  List<Make> _makes = [];
  List<Model> _models = [];
  List<SubModel> _subModels = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _suppliers = [];
  Map<String, dynamic>? _selectedCategory;
  Map<String, dynamic>? _selectedSupplier;
  Make? _selectedMake;
  Model? _selectedModel;
  SubModel? _selectedSubModel;
  Map<String, dynamic>? _selectedPart;
  String _generatedBarcode = '';
  Uint8List? _barcodeImage;
  bool _isGeneratingBarcode = false;
  String? _selectedYear;
  int _selectedTemplateIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _partSearchController.addListener(_onPartSearchChanged);
    _partNameController.addListener(_updateBarcode);
  }

  @override
  void dispose() {
    _partSearchController.removeListener(_onPartSearchChanged);
    _partSearchController.dispose();
    _descriptionController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _currentStockController.dispose();
    _minimumStockController.dispose();
    _searchController.dispose();
    _partNameController.dispose();
    _oemNumberController.dispose();
    _locationAisleController.dispose();
    _locationShelfController.dispose();
    _locationBinController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _warrantyPeriodController.dispose();
    _yearFromController.dispose();
    _yearToController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadMakes(),
        _loadCategories(),
        _loadSuppliers(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMakes() async {
    setState(() => _isLoading = true);
    try {
      final makes = await _makeRepository.getAllMakes();
      setState(() => _makes = makes);
    } catch (e) {
      _showError('Markalar yüklenirken bir hata oluştu');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadModels(int makeId) async {
    setState(() => _isLoading = true);
    try {
      final models = await _modelRepository.getModelsByMake(makeId);
      setState(() {
        _models = models;
        _selectedModel = null;
      });
    } catch (e) {
      _showError('Modeller yüklenirken bir hata oluştu');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSubModels(int modelId) async {
    setState(() => _isLoading = true);
    try {
      final subModels = await _subModelRepository.getSubModelsByModel(modelId);
      setState(() {
        _subModels = subModels;
        _selectedSubModel = null;
      });
    } catch (e) {
      setState(() {
        _subModels = [];
        _selectedSubModel = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      print('Kategoriler yükleniyor...');
      final response = await _dio.get(AppConfig.categoriesEndpoint);
      print('Kategori API yanıtı: ${response.data}');

      if (response.statusCode == 200) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response.data);
          _selectedCategory = null;
        });
      } else {
        print('Kategoriler yüklenirken hata: ${response.statusCode} - ${response.data}');
        _showError('Kategoriler yüklenirken bir hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Kategoriler yüklenirken hata: $e');
      _showError('Kategoriler yüklenirken bir hata oluştu');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoading = true);
    try {
      print('Tedarikçiler yükleniyor...');
      final response = await _dio.get(AppConfig.suppliersEndpoint);
      print('Tedarikçi API yanıtı: ${response.data}');

      if (response.statusCode == 200) {
        setState(() {
          _suppliers = List<Map<String, dynamic>>.from(response.data);
          _selectedSupplier = null;
        });
      } else {
        print('Tedarikçiler yüklenirken hata: ${response.statusCode} - ${response.data}');
        _showError('Tedarikçiler yüklenirken bir hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Tedarikçiler yüklenirken hata: $e');
      _showError('Tedarikçiler yüklenirken bir hata oluştu');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onCategorySelected(Map<String, dynamic>? category) {
    setState(() {
      _selectedCategory = category;
    });
    _updateBarcode();
  }

  void _onMakeSelected(Make? make) {
    setState(() {
      _selectedMake = make;
      _selectedModel = null;
      _selectedSubModel = null;
      _models = [];
      _subModels = [];
    });
    if (make != null) {
      _loadModels(make.makeId);
    }
    _updateBarcode();
  }

  void _onModelSelected(Model? model) {
    setState(() {
      _selectedModel = model;
      _selectedSubModel = null;
      _subModels = [];
    });
    if (model != null) {
      _loadSubModels(model.modelId);
    }
    _updateBarcode();
  }

  void _onSubModelSelected(SubModel? subModel) {
    setState(() {
      _selectedSubModel = subModel;
    });
    _updateBarcode();
  }

  void _onYearSelected(String? year) {
    setState(() {
      _selectedYear = year;
    });
    _updateBarcode();
  }

  String _getPartNameCode(String partName) {
    if (partName.isEmpty) return '';

    // Türkçe karakterleri İngilizce karakterlere çevir
    final turkishToEmglish = {
      'ç': 'c',
      'ğ': 'g',
      'ı': 'i',
      'ö': 'o',
      'ş': 's',
      'ü': 'u',
      'Ç': 'C',
      'Ğ': 'G',
      'İ': 'I',
      'Ö': 'O',
      'Ş': 'S',
      'Ü': 'U'
    };

    String normalizedName = partName;
    turkishToEmglish.forEach((turkish, english) {
      normalizedName = normalizedName.replaceAll(turkish, english);
    });

    // Kelimelere ayır
    final words = normalizedName.split(' ');

    if (words.length == 1) {
      // Tek kelime ise ilk iki harfi al
      return words[0].length >= 2 ? words[0].substring(0, 2).toUpperCase() : words[0].padRight(2, 'X').toUpperCase();
    } else {
      // Birden fazla kelime ise ilk iki kelimenin ilk harflerini al
      String code = '';
      for (int i = 0; i < words.length && code.length < 2; i++) {
        if (words[i].isNotEmpty) {
          code += words[i][0];
        }
      }
      return code.padRight(2, 'X').toUpperCase();
    }
  }

  void _updateBarcode() {
    if (_selectedMake == null ||
        _selectedModel == null ||
        _selectedCategory == null ||
        _yearFromController.text.isEmpty) {
      setState(() {
        _generatedBarcode = '';
      });
      return;
    }

    final partCode = _getPartNameCode(_partNameController.text);
    final yearFrom = int.tryParse(_yearFromController.text) ?? 0;
    final yearTo = int.tryParse(_yearToController.text) ?? yearFrom;

    final barcodeNumber = '$partCode'
        '${_selectedMake!.makeId.toString().padLeft(3, '0')}'
        '${_selectedModel!.modelId.toString().padLeft(3, '0')}'
        '${yearFrom.toString().substring(2)}'
        '${yearTo.toString().substring(2)}';

    setState(() {
      _generatedBarcode = barcodeNumber;
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _partSearchController.clear();
    _descriptionController.clear();
    _buyPriceController.clear();
    _sellPriceController.clear();
    _currentStockController.clear();
    _minimumStockController.clear();
    _searchController.clear();
    _partNameController.clear();
    _oemNumberController.clear();
    _locationAisleController.clear();
    _locationShelfController.clear();
    _locationBinController.clear();
    _notesController.clear();
    _weightController.clear();
    _dimensionsController.clear();
    _warrantyPeriodController.clear();
    _yearFromController.clear();
    _yearToController.clear();
    _isActive = true;
    setState(() {
      _selectedCategory = null;
      _selectedSupplier = null;
      _selectedMake = null;
      _selectedModel = null;
      _selectedSubModel = null;
      _selectedYear = null;
      _searchResults = [];
    });
  }

  void _savePart() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> data = {
        'part_number': _generatedBarcode.isNotEmpty ? _generatedBarcode : _partNameController.text,
        'description': _descriptionController.text,
        'category_id': _selectedCategory?['category_id'],
        'make_id': _selectedMake?.makeId,
        'model_id': _selectedModel?.modelId,
        'submodel_id': _selectedSubModel?.submodelId,
        'buy_price': double.tryParse(_buyPriceController.text) ?? 0.0,
        'sell_price': double.tryParse(_sellPriceController.text) ?? 0.0,
        'current_stock': int.tryParse(_currentStockController.text) ?? 0,
        'minimum_stock': int.tryParse(_minimumStockController.text) ?? 0,
        'is_active': _isActive,
        'oem_code': _oemNumberController.text,
        'barcode': _generatedBarcode,
        'location_aisle': _locationAisleController.text,
        'location_shelf': _locationShelfController.text,
        'location_bin': _locationBinController.text,
        'notes': _notesController.text,
        'weight_kg': double.tryParse(_weightController.text),
        'dimensions_cm': _dimensionsController.text,
        'warranty_period': _warrantyPeriodController.text,
        'supplier_id': _selectedSupplier?['supplier_id'],
        'year_from': int.tryParse(_yearFromController.text),
        'year_to': int.tryParse(_yearToController.text),
      };

      print('Gönderilen veri: $data');

      final response = await http.post(
        Uri.parse(AppConfig.itemsEndpoint),
        headers: AppConfig.headers,
        body: jsonEncode(data),
      );

      print('API Yanıtı: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parça başarıyla eklendi'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        _clearForm();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Parça eklenirken bir hata oluştu: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Formu temizlemek için yeni method
  void _clearForm() {
    setState(() {
      _partNameController.clear();
      _descriptionController.clear();
      _oemNumberController.clear();
      _buyPriceController.clear();
      _sellPriceController.clear();
      _currentStockController.clear();
      _minimumStockController.clear();
      _locationAisleController.clear();
      _locationShelfController.clear();
      _locationBinController.clear();
      _notesController.clear();
      _weightController.clear();
      _dimensionsController.clear();
      _warrantyPeriodController.clear();
      _yearFromController.clear();
      _yearToController.clear();
      _generatedBarcode = '';

      // Dropdown seçimlerini sıfırla
      _selectedCategory = null;
      _selectedSupplier = null;
      _selectedMake = null;
      _selectedModel = null;
      _selectedSubModel = null;
      _selectedYear = null;

      // Model ve submodel listelerini temizle
      _models = [];
      _subModels = [];
    });
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onPartSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_partSearchController.text.isNotEmpty) {
        _searchParts(_partSearchController.text);
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _searchParts(String query) async {
    setState(() => _isSearching = true);
    try {
      final response = await _dio.get(
        AppConfig.searchEndpoint,
        queryParameters: {'query': query},
      );
      if (response.statusCode == 200) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      _showError('Parça arama sırasında bir hata oluştu');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectPart(Map<String, dynamic> part) {
    setState(() {
      _selectedPart = part;
      _partNameController.text = part['part_number'] ?? '';
      _descriptionController.text = part['description'] ?? '';
      _buyPriceController.text = part['buy_price']?.toString() ?? '';
      _sellPriceController.text = part['sell_price']?.toString() ?? '';
      _currentStockController.text = part['current_stock']?.toString() ?? '';
      _minimumStockController.text = part['minimum_stock']?.toString() ?? '';
      _oemNumberController.text = part['oem_number'] ?? '';
      _locationAisleController.text = part['location_aisle'] ?? '';
      _locationShelfController.text = part['location_shelf'] ?? '';
      _locationBinController.text = part['location_bin'] ?? '';
      _notesController.text = part['notes'] ?? '';
      _yearFromController.text = part['year_from']?.toString() ?? '';
      _yearToController.text = part['year_to']?.toString() ?? '';

      // Kategori seçimi
      _selectedCategory = _categories.firstWhere(
        (category) => category['category_id'] == part['category_id'],
        orElse: () => <String, dynamic>{},
      );

      // Tedarikçi seçimi
      _selectedSupplier = _suppliers.firstWhere(
        (supplier) => supplier['supplier_id'] == part['supplier_id'],
        orElse: () => <String, dynamic>{},
      );
    });
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final TextEditingController categoryNameController = TextEditingController();
    final TextEditingController categoryDescController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kategori Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryNameController,
              decoration: const InputDecoration(
                labelText: 'Kategori Adı',
                hintText: 'Kategori adını girin',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: categoryDescController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Kategori açıklaması girin',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (categoryNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kategori adı boş olamaz')),
                );
                return;
              }

              try {
                final response = await _categoryRepository.createCategory(
                  name: categoryNameController.text,
                  description: categoryDescController.text.isEmpty ? null : categoryDescController.text,
                );

                if (mounted) {
                  setState(() {
                    _categories.add(response);
                    _selectedCategory = response;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kategori başarıyla eklendi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Kategorileri yeniden yükle
                  _loadCategories();
                }
              } catch (e) {
                print('Kategori ekleme hatası: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kategori eklenirken bir hata oluştu: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSupplierDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController contactPersonController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController taxNumberController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Tedarikçi Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tedarikçi Adı *',
                  hintText: 'Tedarikçi adını girin',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contactPersonController,
                decoration: const InputDecoration(
                  labelText: 'İletişim Kişisi *',
                  hintText: 'İletişim kişisinin adını girin',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon *',
                  hintText: 'Telefon numarasını girin',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  hintText: 'E-posta adresini girin',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Adres',
                  hintText: 'Adresi girin',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: taxNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vergi Numarası',
                  hintText: 'Vergi numarasını girin',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  hintText: 'Notları girin',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || contactPersonController.text.isEmpty || phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tedarikçi adı, iletişim kişisi ve telefon zorunludur'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final response = await _dio.post(
                  AppConfig.suppliersEndpoint,
                  data: {
                    'name': nameController.text,
                    'contact_person': contactPersonController.text,
                    'phone': phoneController.text,
                    'email': emailController.text.isEmpty ? null : emailController.text,
                    'address': addressController.text.isEmpty ? null : addressController.text,
                    'tax_number': taxNumberController.text.isEmpty ? null : taxNumberController.text,
                    'notes': notesController.text.isEmpty ? null : notesController.text,
                    'is_active': true,
                  },
                );

                if (response.statusCode == 201) {
                  if (mounted) {
                    setState(() {
                      _suppliers.add(response.data);
                      _selectedSupplier = response.data;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tedarikçi başarıyla eklendi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Tedarikçileri yeniden yükle
                    _loadSuppliers();
                  }
                } else {
                  throw Exception('Tedarikçi eklenirken bir hata oluştu: ${response.statusCode}');
                }
              } catch (e) {
                print('Tedarikçi ekleme hatası: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tedarikçi eklenirken bir hata oluştu: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Parça Ekle'),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/stock'),
            icon: const Icon(Icons.inventory, color: Colors.white),
            label: const Text('Stok Listesi', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol Kolon
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Araç Seçim Kartı
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Araç Bilgileri',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<Make>(
                                    value: _selectedMake,
                                    decoration: const InputDecoration(
                                      labelText: 'Marka *',
                                      hintText: 'Marka seçiniz',
                                    ),
                                    items: _makes.map((make) {
                                      return DropdownMenuItem(
                                        value: make,
                                        child: Text(make.makeName),
                                      );
                                    }).toList(),
                                    onChanged: _onMakeSelected,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Lütfen marka seçiniz';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<Model>(
                                    value: _selectedModel,
                                    decoration: const InputDecoration(
                                      labelText: 'Model *',
                                      hintText: 'Model seçiniz',
                                    ),
                                    items: _models.map((model) {
                                      return DropdownMenuItem(
                                        value: model,
                                        child: Text(
                                          model.modelName,
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: _onModelSelected,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Lütfen model seçiniz';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<SubModel>(
                                    value: _selectedSubModel,
                                    decoration: const InputDecoration(
                                      labelText: 'Alt Model',
                                      hintText: 'Alt model seçiniz',
                                    ),
                                    items: _subModels.map((submodel) {
                                      return DropdownMenuItem(
                                        value: submodel,
                                        child: Text(
                                          '${submodel.submodelName} (${submodel.yearFrom}-${submodel.yearTo ?? 'Devam'}) - ${submodel.engineDisplacement}L ${submodel.fuelType}',
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: _onSubModelSelected,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Yıl Aralığı Kartı
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Yıl Aralığı',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _yearFromController,
                                          decoration: const InputDecoration(
                                            labelText: 'Başlangıç Yılı',
                                            hintText: 'Örn: 2015',
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return null; // Artık zorunlu değil
                                            }
                                            final year = int.tryParse(value);
                                            if (year == null) {
                                              return 'Geçerli bir yıl girin';
                                            }
                                            if (year < 1900 || year > 2100) {
                                              return 'Yıl 1900-2100 arasında olmalı';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _yearToController,
                                          decoration: const InputDecoration(
                                            labelText: 'Bitiş Yılı',
                                            hintText: 'Örn: 2020',
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return null; // Artık zorunlu değil
                                            }
                                            final year = int.tryParse(value);
                                            if (year == null) {
                                              return 'Geçerli bir yıl girin';
                                            }
                                            if (year < 1900 || year > 2100) {
                                              return 'Yıl 1900-2100 arasında olmalı';
                                            }
                                            final fromYear = int.tryParse(_yearFromController.text);
                                            if (fromYear != null && year < fromYear) {
                                              return 'Bitiş yılı başlangıç yılından küçük olamaz';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          // Parça Bilgileri Kartı
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Parça Bilgileri',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<Map<String, dynamic>>(
                                    value: _selectedCategory,
                                    decoration: const InputDecoration(
                                      labelText: 'Kategori',
                                      hintText: 'Kategori seçin',
                                    ),
                                    items: _categories.map((category) {
                                      return DropdownMenuItem(
                                        value: category,
                                        child: Text(
                                          category['name'] ?? '',
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Lütfen kategori seçin';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      _showAddCategoryDialog(context);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Yeni Kategori Ekle'),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _partNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Parça Adı *',
                                      hintText: 'Parça adını girin',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Lütfen parça adını girin';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _descriptionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Açıklama *',
                                      hintText: 'Parça açıklamasını girin',
                                    ),
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Lütfen parça açıklamasını girin';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _oemNumberController,
                                    decoration: const InputDecoration(
                                      labelText: 'OEM Numarası',
                                      hintText: 'Orijinal parça numarasını girin',
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  DropdownButtonFormField<Map<String, dynamic>>(
                                    value: _selectedSupplier,
                                    decoration: const InputDecoration(
                                      labelText: 'Tedarikçi',
                                      hintText: 'Tedarikçi seçin',
                                    ),
                                    items: _suppliers.map((supplier) {
                                      return DropdownMenuItem(
                                        value: supplier,
                                        child: Text(
                                          supplier['name'] ?? '',
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSupplier = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      _showAddSupplierDialog(context);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Yeni Tedarikçi Ekle'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sağ Kolon
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Stok ve Fiyat Bilgileri Kartı
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Stok ve Fiyat Bilgileri',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _buyPriceController,
                                          decoration: const InputDecoration(
                                            labelText: 'Alış Fiyatı *',
                                            hintText: 'Alış fiyatını girin',
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Lütfen alış fiyatını girin';
                                            }
                                            if (double.tryParse(value) == null) {
                                              return 'Geçerli bir fiyat girin';
                                            }
                                            if (double.parse(value) <= 0) {
                                              return 'Alış fiyatı 0\'dan büyük olmalıdır';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _sellPriceController,
                                          decoration: const InputDecoration(
                                            labelText: 'Satış Fiyatı *',
                                            hintText: 'Satış fiyatını girin',
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Lütfen satış fiyatını girin';
                                            }
                                            if (double.tryParse(value) == null) {
                                              return 'Geçerli bir fiyat girin';
                                            }
                                            if (double.parse(value) <= 0) {
                                              return 'Satış fiyatı 0\'dan büyük olmalıdır';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _currentStockController,
                                          decoration: const InputDecoration(
                                            labelText: 'Mevcut Stok *',
                                            hintText: 'Mevcut stok miktarını girin',
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Lütfen stok miktarını girin';
                                            }
                                            if (int.tryParse(value) == null) {
                                              return 'Geçerli bir sayı girin';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _minimumStockController,
                                          decoration: const InputDecoration(
                                            labelText: 'Minimum Stok *',
                                            hintText: 'Minimum stok miktarını girin',
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Lütfen minimum stok miktarını girin';
                                            }
                                            if (int.tryParse(value) == null) {
                                              return 'Geçerli bir sayı girin';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Konum Bilgileri Kartı
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Konum Bilgileri',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _locationAisleController,
                                          decoration: const InputDecoration(
                                            labelText: 'Koridor',
                                            hintText: 'Koridor numarası',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _locationShelfController,
                                          decoration: const InputDecoration(
                                            labelText: 'Raf',
                                            hintText: 'Raf numarası',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _locationBinController,
                                          decoration: const InputDecoration(
                                            labelText: 'Kutu',
                                            hintText: 'Kutu numarası',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Barkod Şablonları Kartı
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Barkod Şablonları',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          if (_selectedTemplateIndex == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Lütfen bir şablon seçin'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          final result = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Yazdırma'),
                                              content: const Text(
                                                  'Seçili şablon yazdırılacak. Devam etmek istiyor musunuz?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('İptal'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('Yazdır'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (result == true) {
                                            try {
                                              final templateData = {
                                                'barcode': _generatedBarcode,
                                                'make': _selectedMake?.makeName ?? '',
                                                'model': _selectedModel?.modelName ?? '',
                                                'submodel': _selectedSubModel?.submodelName ?? '',
                                                'yearRange': '${_yearFromController.text}-${_yearToController.text}',
                                                'partNumber': _partNameController.text,
                                                'category': _selectedCategory?['name'] ?? '',
                                                'oem': _oemNumberController.text,
                                                'description': _descriptionController.text,
                                                'stock': _currentStockController.text,
                                                'minStock': _minimumStockController.text,
                                                'location':
                                                    '${_locationAisleController.text}-${_locationShelfController.text}-${_locationBinController.text}',
                                              };

                                              await PrintService.printBarcode(templateData, _selectedTemplateIndex);

                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Yazdırma işlemi başarıyla tamamlandı'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Yazdırma hatası: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.print),
                                        label: const Text('Yazdır'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 400, // Sabit yükseklik
                                    child: SingleChildScrollView(
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
                                                    if (index >= 1) ...[
                                                      Text(
                                                        'Araç: ${_selectedMake?.makeName ?? ""} ${_selectedModel?.modelName ?? ""} ${_selectedSubModel?.submodelName ?? ""}',
                                                        style: TextStyle(
                                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Yıl: ${_yearFromController.text}-${_yearToController.text}',
                                                        style: TextStyle(
                                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                    if (index >= 2) ...[
                                                      Text(
                                                        'OEM: ${_oemNumberController.text}',
                                                        style: TextStyle(
                                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Açıklama: ${_descriptionController.text}',
                                                        style: TextStyle(
                                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                    if (index >= 3) ...[
                                                      Text(
                                                        'Kategori: ${_selectedCategory?['name'] ?? ""}',
                                                        style: TextStyle(
                                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Parça Adı: ${_partNameController.text}',
                                                        style: TextStyle(
                                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                    if (index >= 4) ...[
                                                      Text(
                                                        'Stok: ${_currentStockController.text}',
                                                        style: TextStyle(
                                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Raf: ${_locationAisleController.text}-${_locationShelfController.text}-${_locationBinController.text}',
                                                        style: TextStyle(
                                                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                    const SizedBox(height: 16),
                                                    Center(
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            width: 200,
                                                            height: 100,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.grey.shade300),
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            child: _generatedBarcode.isEmpty
                                                                ? const Center(
                                                                    child: Text(
                                                                      'Barkod\nGörüntüsü',
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        color: Colors.grey,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : BarcodeWidget(
                                                                    barcode: Barcode.code128(),
                                                                    data: _generatedBarcode,
                                                                    width: 180,
                                                                    height: 80,
                                                                    drawText: false,
                                                                  ),
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Text(
                                                            _generatedBarcode.isEmpty ? 'Barkod No' : _generatedBarcode,
                                                            style: TextStyle(
                                                              color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _savePart,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Kaydet'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

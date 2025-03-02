import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/make_model.dart';
import '../../data/repositories/make_repository.dart';

class MakesPage extends StatefulWidget {
  const MakesPage({super.key});

  @override
  State<MakesPage> createState() => _MakesPageState();
}

class _MakesPageState extends State<MakesPage> {
  final _makeRepository = GetIt.instance<MakeRepository>();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;
  List<Make> _makes = [];

  @override
  void initState() {
    super.initState();
    _loadMakes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

  Future<void> _addMake() async {
    if (_nameController.text.isEmpty) {
      _showError('Lütfen marka adını girin');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final make = await _makeRepository.createMake(
        name: _nameController.text,
      );
      setState(() {
        _makes.add(make);
        _nameController.clear();
      });
    } catch (e) {
      _showError('Marka eklenirken bir hata oluştu');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateMake(Make make) async {
    setState(() => _isLoading = true);
    try {
      final updatedMake = await _makeRepository.updateMake(make);
      setState(() {
        final index = _makes.indexWhere((m) => m.makeId == make.makeId);
        if (index != -1) {
          _makes[index] = updatedMake;
        }
      });
    } catch (e) {
      _showError('Marka güncellenirken bir hata oluştu');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMake(Make make) async {
    setState(() => _isLoading = true);
    try {
      await _makeRepository.deleteMake(make.makeId);
      setState(() {
        _makes.removeWhere((m) => m.makeId == make.makeId);
      });
    } catch (e) {
      _showError('Marka silinirken bir hata oluştu');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
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
        title: const Text('Markalar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Marka Adı',
                            hintText: 'Yeni marka adını girin',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _addMake,
                        child: const Text('Ekle'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _makes.length,
                    itemBuilder: (context, index) {
                      final make = _makes[index];
                      return ListTile(
                        title: Text(make.makeName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // TODO: Edit make
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteMake(make),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
} 
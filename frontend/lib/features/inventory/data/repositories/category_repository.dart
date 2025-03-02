import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryRepository {
  final String baseUrl = 'http://localhost:8080/api';

  // Tüm kategorileri getir
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } else {
      throw Exception('Kategoriler yüklenirken bir hata oluştu');
    }
  }

  // Kategori ara
  Future<List<Map<String, dynamic>>> searchCategories(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/search?q=$query'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Kategoriler yüklenirken bir hata oluştu: ${response.body}');
    }
  }

  // Yeni kategori ekle
  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Kategori eklenirken bir hata oluştu: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCategoryById(int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$categoryId'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Kategori yüklenirken bir hata oluştu: ${response.body}');
    }
  }
}

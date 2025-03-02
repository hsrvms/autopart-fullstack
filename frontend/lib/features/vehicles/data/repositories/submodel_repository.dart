import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/submodel_model.dart';

class SubModelRepository {
  final String baseUrl = 'http://localhost:8080/api';

  Future<List<SubModel>> getSubModelsByModel(int modelId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/models/$modelId/submodels'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => SubModel.fromJson(json)).toList();
    } else {
      throw Exception('Alt modeller yüklenirken bir hata oluştu');
    }
  }
}

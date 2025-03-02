import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/model_model.dart';
import '../../../../core/config/app_config.dart';

class ModelRepository {
  Future<List<Model>> getModelsByMake(int makeId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.makesEndpoint}/$makeId/models'),
      headers: AppConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Model.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load models');
    }
  }

  Future<Model> getModelById(int id) async {
    final response = await http.get(
      Uri.parse('${AppConfig.modelsEndpoint}/$id'),
      headers: AppConfig.headers,
    );

    if (response.statusCode == 200) {
      return Model.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load model');
    }
  }
}

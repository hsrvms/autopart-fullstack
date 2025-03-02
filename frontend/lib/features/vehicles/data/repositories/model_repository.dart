import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/model_model.dart';

class ModelRepository {
  final String baseUrl;

  ModelRepository({this.baseUrl = 'http://localhost:8080/api'});

  Future<List<Model>> getModelsByMake(int makeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/makes/$makeId/models'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
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
      Uri.parse('$baseUrl/models/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Model.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load model');
    }
  }
}

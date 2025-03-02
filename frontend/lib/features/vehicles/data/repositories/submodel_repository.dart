import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/submodel_model.dart';
import '../../../../core/config/app_config.dart';

class SubModelRepository {
  Future<List<SubModel>> getSubModelsByModel(int modelId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.modelsEndpoint}/$modelId/submodels'),
      headers: AppConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => SubModel.fromJson(json)).toList();
    } else {
      throw Exception('Alt modeller yüklenirken bir hata oluştu');
    }
  }
}

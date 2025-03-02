import 'package:get_it/get_it.dart';
import '../../../../core/api/api_client.dart';
import '../models/vehicle_models.dart';

class VehicleRepository {
  final ApiClient _apiClient = GetIt.instance<ApiClient>();

  Future<List<Make>> getMakes() async {
    final response = await _apiClient.get('/makes');
    return (response.data as List).map((json) => Make.fromJson(json)).toList();
  }

  Future<List<Model>> getModelsByMake(int makeId) async {
    final response = await _apiClient.get('/makes/$makeId/models');
    return (response.data as List).map((json) => Model.fromJson(json)).toList();
  }

  Future<List<Submodel>> getSubmodelsByModel(int modelId) async {
    final response = await _apiClient.get('/models/$modelId/submodels');
    return (response.data as List).map((json) => Submodel.fromJson(json)).toList();
  }

  Future<Make> createMake(String makeName, String? country) async {
    final response = await _apiClient.post('/makes', data: {
      'make_name': makeName,
      'country': country,
    });
    return Make.fromJson(response.data);
  }

  Future<Model> createModel(int makeId, String modelName) async {
    final response = await _apiClient.post('/models', data: {
      'make_id': makeId,
      'model_name': modelName,
    });
    return Model.fromJson(response.data);
  }

  Future<Submodel> createSubmodel(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/submodels', data: data);
    return Submodel.fromJson(response.data);
  }
} 
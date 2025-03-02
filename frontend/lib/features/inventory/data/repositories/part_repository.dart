import 'dart:convert';
import 'package:get_it/get_it.dart';
import '../../../../core/api/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class PartRepository {
  final Dio _dio;

  PartRepository(this._dio);

  Future<List<dynamic>> getAllParts() async {
    try {
      final response = await _dio.get('/api/items');

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }

      throw Exception('Parçalar yüklenirken bir hata oluştu');
    } catch (e) {
      throw Exception('Parçalar yüklenirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<List<dynamic>> searchParts(String query) async {
    try {
      final response = await _dio.get('/api/items', queryParameters: {
        'search': query,
      });

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }

      throw Exception('Parça araması yapılırken bir hata oluştu');
    } catch (e) {
      throw Exception('Parça araması yapılırken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getPartById(int id) async {
    try {
      final response = await _dio.get('/api/items/$id');
      return response.data;
    } catch (e) {
      throw Exception('Parça detayları yüklenirken bir hata oluştu: $e');
    }
  }

  Future<Map<String, dynamic>> createPart(Map<String, dynamic> part) async {
    try {
      final response = await _dio.post('/api/items', data: part);

      if (response.statusCode == 201) {
        return response.data;
      }

      throw Exception('Parça eklenirken bir hata oluştu');
    } catch (e) {
      throw Exception('Parça eklenirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updatePart(int id, Map<String, dynamic> part) async {
    try {
      final response = await _dio.put('/api/items/$id', data: part);

      if (response.statusCode == 200) {
        return response.data;
      }

      throw Exception('Parça güncellenirken bir hata oluştu');
    } catch (e) {
      throw Exception('Parça güncellenirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<void> deletePart(int id) async {
    try {
      final response = await _dio.delete('/api/items/$id');

      if (response.statusCode != 204) {
        throw Exception('Parça silinirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Parça silinirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getLowStockParts() async {
    try {
      final response = await _dio.get('/api/items/low-stock');

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }

      throw Exception('Düşük stoklu parçalar yüklenirken bir hata oluştu');
    } catch (e) {
      throw Exception('Düşük stoklu parçalar yüklenirken bir hata oluştu: ${e.toString()}');
    }
  }
}

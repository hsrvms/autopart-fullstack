import 'package:dio/dio.dart';
import '../models/make_model.dart';

class MakeRepository {
  final Dio _dio;

  MakeRepository(this._dio);

  Future<List<Make>> getAllMakes() async {
    try {
      final response = await _dio.get('/makes');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Make.fromJson(json)).toList();
      }

      throw Exception('Markalar yüklenirken bir hata oluştu');
    } catch (e) {
      throw Exception('Markalar yüklenirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<Make> getMakeById(int id) async {
    try {
      final response = await _dio.get('/makes/$id');
      return Make.fromJson(response.data);
    } catch (e) {
      throw Exception('Marka detayları yüklenirken bir hata oluştu: $e');
    }
  }

  Future<Make> createMake({required String name}) async {
    try {
      final response = await _dio.post('/makes', data: {
        'make_name': name,
      });

      if (response.statusCode == 201) {
        return Make.fromJson(response.data);
      }

      throw Exception('Marka eklenirken bir hata oluştu');
    } catch (e) {
      throw Exception('Marka eklenirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<Make> updateMake(Make make) async {
    try {
      final response = await _dio.put('/makes/${make.makeId}', data: {
        'make_name': make.makeName,
      });

      if (response.statusCode == 200) {
        return Make.fromJson(response.data);
      }

      throw Exception('Marka güncellenirken bir hata oluştu');
    } catch (e) {
      throw Exception('Marka güncellenirken bir hata oluştu: ${e.toString()}');
    }
  }

  Future<void> deleteMake(int makeId) async {
    try {
      final response = await _dio.delete('/makes/$makeId');

      if (response.statusCode != 204) {
        throw Exception('Marka silinirken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Marka silinirken bir hata oluştu: ${e.toString()}');
    }
  }
}

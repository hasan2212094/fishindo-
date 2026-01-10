import 'package:fishindo_app/core/api/jenisikan_api.dart';
import 'package:fishindo_app/data/models/jenisikan_model.dart';
import 'package:fishindo_app/data/models/ikan_model.dart';
import 'package:fishindo_app/data/models/success_model.dart';
import 'package:logger/logger.dart';

class JenisikanRepository {
  final JenisikanApi jenisikanApi;
  final _logger = Logger();

  JenisikanRepository({required this.jenisikanApi});

  /// 🔹 Ambil semua jenis ikan (aktif), diurutkan berdasarkan createdAt
  /// Ambil semua jenis ikan aktif
  /// Ambil semua jenis ikan aktif
  Future<List<JenisIkanModel>> getJenisikanAll() async {
    try {
      _logger.i("Fetching all jenis ikan...");
      final response = await jenisikanApi.listJenisikanAll();

      return response
          .map<JenisIkanModel>((json) => JenisIkanModel.fromJson(json))
          .toList()
        ..sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
    } catch (e, stack) {
      _logger.e("Error getJenisikanAll()", error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 🔹 Ambil jenis ikan berdasarkan ikan_id
  Future<List<JenisIkanModel>> getJenisikanByIkan(int ikanId) async {
    try {
      _logger.i("Fetching jenis ikan by ikan ID: $ikanId");

      final response = await jenisikanApi.listJenisikanByIkan(ikanId);

      return response
          .map<JenisIkanModel>((json) => JenisIkanModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e(
        "Error getJenisikanByIkan($ikanId)",
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// 🔹 Ambil detail jenis ikan berdasarkan ID
  Future<JenisIkanModel> getById(int id) async {
    try {
      final response = await jenisikanApi.getById(id);
      return JenisIkanModel.fromJson(response);
    } catch (e, stack) {
      _logger.e("Error getById($id)", error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 🔹 Tambah jenis ikan
  Future<SuccessModel> create(String name, int ikanId) async {
    try {
      final response = await jenisikanApi.create(name, ikanId);
      return SuccessModel.fromJson(response);
    } catch (e, stack) {
      _logger.e("Error create jenis ikan", error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 🔹 Update jenis ikan
  Future<SuccessModel> update(int id, String name, int ikanId) async {
    try {
      final response = await jenisikanApi.update(id, name, ikanId);
      return SuccessModel.fromJson(response);
    } catch (e, stack) {
      _logger.e("Error update jenis ikan ($id)", error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 🔹 Delete permanen jenis ikan
  Future<SuccessModel> delete(int id) async {
    try {
      final response = await jenisikanApi.delete(id);
      return SuccessModel.fromJson(response);
    } catch (e, stack) {
      _logger.e("Error delete jenis ikan ($id)", error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 🔹 Ambil master ikan (untuk dropdown)
  Future<List<IkanModel>> getIkan() async {
    try {
      final response = await jenisikanApi.fetchIkan();
      return response
          .map<IkanModel>((json) => IkanModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e("Error fetch ikan master", error: e, stackTrace: stack);
      rethrow;
    }
  }
}

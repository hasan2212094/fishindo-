import 'dart:io';
import 'package:logger/logger.dart';
import 'package:fishindo_app/data/models/fishindo_model.dart';
import 'package:fishindo_app/data/models/success_model.dart';
import 'package:fishindo_app/data/models/jenisikan_model.dart';
import '../../core/api/fishindo_api.dart';
import '../../core/services/storage_service.dart';

class FishindoRepository {
  final FishindoApi fishindoApi;
  final _logger = Logger();

  FishindoRepository({required this.fishindoApi});

  /// 🔹 Ambil semua data maintenance (aktif saja)
  Future<List<FishindoModel>> getFishindoAll() async {
    try {
      _logger.i("Fetching all fishindo data...");
      final response = await fishindoApi.listFishindoAll();

      final data =
          response
              .map<FishindoModel>((json) => FishindoModel.fromJson(json))
              .toList()
            ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

      _logger.i("Total fishindo fetched: ${data.length}");
      return data;
    } catch (e, stack) {
      _logger.e("Error getFishindoAll()", error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 🔹 Ambil data fishindo berdasarkan jenis ikan
  Future<List<FishindoModel>> getFishindoByJenis(int jenisIkanId) async {
    try {
      _logger.i("Fetching fishindo by jenis ikan ID: $jenisIkanId");

      final response = await fishindoApi.listFishindoByJenis(jenisIkanId);

      final data =
          response
              .map<FishindoModel>((json) => FishindoModel.fromJson(json))
              .toList()
            ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

      _logger.i("Total fishindo by jenis fetched: ${data.length}");
      return data;
    } catch (e, stack) {
      _logger.e(
        "Error getFishindoByJenis($jenisIkanId)",
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// 🔹 Ambil semua data termasuk yang terhapus
  Future<List<FishindoModel>> getAll() async {
    try {
      _logger.i("Fetching all (with deleted) electrical data...");
      final response = await fishindoApi.getAllWithTrashed();
      return response
          .map<FishindoModel>((json) => FishindoModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e("Error getAll()", error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 🔹 Ambil data berdasarkan ID
  Future<FishindoModel> getById(int id) async {
    try {
      _logger.i("Fetching fishindo by ID: $id");
      final response = await fishindoApi.getById(id);
      return FishindoModel.fromJson(response);
    } catch (e, stack) {
      _logger.e("Error getById($id)", error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 🔹 Create / Tambah data baru
  Future<SuccessModel> create(
    String lokasi,
    String nelayan,
    double timbangan,
    double harga,
    int jenisikanId,
    List<File> imagesFish,
    List<File> imagesTimbangan,
  ) async {
    final response = await fishindoApi.create(
      lokasi,
      nelayan,
      timbangan,
      harga,
      jenisikanId,
      imagesFish,
      imagesTimbangan,
    );

    return SuccessModel.fromJson(response);
  }

  /// 🔹 Update data maintenance
  Future<SuccessModel> update(
    int id,
    String lokasi,
    String nelayan,
    double timbangan,
    double harga,
    int jenisikanId,
  ) async {
    try {
      final userIdBy = await StorageService.getUserId();
      if (userIdBy == null) throw Exception("User ID belum ditemukan.");

      _logger.i("Updating electrical ID: $id");

      final response = await fishindoApi.update(
        id,
        int.parse(userIdBy),
        int.parse(userIdBy),
        lokasi,
        nelayan,
        timbangan,
        harga,
        jenisikanId,
      );

      _logger.i("Update success: $response");
      return SuccessModel.fromJson(response);
    } catch (e, stack) {
      _logger.e("Error update($id)", error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 🔹 Delete sementara (soft delete)
  Future<SuccessModel> delete(int id) async {
    try {
      _logger.w("Deleting maintenance ID: $id (soft delete)");
      final response = await fishindoApi.deletesementara(id);
      return SuccessModel.fromJson(response);
    } catch (e, stack) {
      _logger.e("Error delete($id)", error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 🔹 Download file Excel
  Future<String?> downloadExcel() async {
    try {
      _logger.i("Downloading maintenance Excel...");
      return await fishindoApi.listFishindoExcel();
    } catch (e, stack) {
      _logger.e("Error downloadExcel()", error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<List<JenisIkanModel>> getJenisikan() async {
    final response = await fishindoApi.fetchJenisikan();

    return response
        .map<JenisIkanModel>((json) => JenisIkanModel.fromJson(json))
        .toList();
  }
}

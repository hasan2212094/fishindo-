import 'package:logger/logger.dart';
import '../../core/api/jenisikan_api.dart';
import 'package:fishindo_app/data/models/success_model.dart';
import '../models/jenisikan_model.dart';

/// Repository bertugas sebagai jembatan antara API dan Provider/UI
class JenisikanRepository {
  final JenisikanApi _api;
  final _logger = Logger();

  JenisikanRepository(this._api);

  /// Ambil semua Jenisikan
  Future<List<JenisIkanModel>> getAllJenisikan() async {
    try {
      _logger.i('🔄 Fetching all Jenisikan...');
      return await _api.getAll();
    } catch (e, st) {
      _logger.e('❌ Error getAllJenisikan: $e', stackTrace: st);
      rethrow;
    }
  }

  /// Ambil 1 jenisikan berdasarkan ID
  Future<JenisIkanModel> getJenisikanById(int id) async {
    try {
      _logger.i('🔍 Fetching Jenisikan ID: $id');
      return await _api.getById(id);
    } catch (e, st) {
      _logger.e('❌ Error getJenisikanById: $e', stackTrace: st);
      rethrow;
    }
  }

  /// Tambah Jenisikan baru
  Future<JenisIkanModel> createJenisikan(String name) async {
    try {
      _logger.i('📤 Creating Jenisikan...');
      return await _api.create(name);
    } catch (e, st) {
      _logger.e('❌ Error createJenisikan: $e', stackTrace: st);
      rethrow;
    }
  }

  /// Update Jenisikan
  Future<JenisIkanModel> updateJenisikan(int id, String name) async {
    try {
      _logger.i('✏️ Updating Jenisikan ID: $id');
      return await _api.update(id, name);
    } catch (e, st) {
      _logger.e('❌ Error updateJenisikan: $e', stackTrace: st);
      rethrow;
    }
  }

  /// Hapus Jenisikan
  Future<SuccessModel> deleteJenisikan(int id) async {
    try {
      _logger.w('🗑️ Deleting Jenisikan ID: $id');
      final result = await _api.delete(id); // hasil dari API
      return result; // ✅ return SuccessModel
    } catch (e, st) {
      _logger.e('❌ Error deleteJenisikan: $e', stackTrace: st);
      rethrow;
    }
  }
}

import 'package:logger/logger.dart';
import '../../core/api/ikan_api.dart';
import 'package:fishindo_app/data/models/success_model.dart';
import '../models/ikan_model.dart';

/// Repository bertugas sebagai jembatan antara API dan Provider/UI
class IkanRepository {
  final IkanApi _api;
  final _logger = Logger();

  IkanRepository(this._api);

  /// Ambil semua Jenisikan
  Future<List<IkanModel>> getAllIkan() async {
    try {
      _logger.i('🔄 Fetching all Ikan...');
      return await _api.getAll();
    } catch (e, st) {
      _logger.e('❌ Error getAllIkan: $e', stackTrace: st);
      rethrow;
    }
  }

  /// Ambil 1 jenisikan berdasarkan ID
  Future<IkanModel> getIkanById(int id) async {
    try {
      _logger.i('🔍 Fetching Ikan ID: $id');
      return await _api.getById(id);
    } catch (e, st) {
      _logger.e('❌ Error getIkanById: $e', stackTrace: st);
      rethrow;
    }
  }

  /// Tambah Jenisikan baru
  Future<IkanModel> createIkan(String name) async {
    try {
      _logger.i('📤 Creating Ikan...');
      return await _api.create(name);
    } catch (e, st) {
      _logger.e('❌ Error createIkan: $e', stackTrace: st);
      rethrow;
    }
  }

  /// Update Jenisikan
  Future<IkanModel> updateIkan(int id, String name) async {
    try {
      _logger.i('✏️ Updating Ikan ID: $id');
      return await _api.update(id, name);
    } catch (e, st) {
      _logger.e('❌ Error updateIkan: $e', stackTrace: st);
      rethrow;
    }
  }

  /// Hapus Jenisikan
  Future<SuccessModel> deleteIkan(int id) async {
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

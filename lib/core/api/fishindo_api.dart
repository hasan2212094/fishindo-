import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../services/storage_service.dart';
import '../../core/config/app_config.dart';

class FishindoApi {
  final Dio dio = Dio();
  final _logger = Logger();

  /// ✅ Ambil semua data maintenance
  Future<List<dynamic>> listFishindoAll() async {
    try {
      final token = await StorageService.getToken();
      const url = '${AppConfig.baseUrl}/fishindo';
      _logger.i('📡 GET: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.i('🔹 Status: ${response.statusCode}');
      _logger.i('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response body');
        }

        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('data')) {
            _logger
                .i('✅ Found key "data" with ${decoded['data'].length} items');
            return decoded['data'] as List<dynamic>;
          } else {
            _logger.w('⚠️ Response Map without "data" key');
            return [];
          }
        } else if (decoded is List) {
          _logger.i('✅ Response is a List with ${decoded.length} items');
          return decoded;
        } else {
          _logger.e('❌ Invalid response format: ${decoded.runtimeType}');
          throw Exception('Invalid response format');
        }
      } else {
        _logger
            .e('❌ HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
        throw Exception("Failed to load fishindo");
      }
    } catch (e, s) {
      _logger.e("❌ Error listFishindoAll", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ✅ Ambil semua data termasuk yang dihapus sementara (soft delete)
  Future<List<dynamic>> getAllWithTrashed() async {
    try {
      final token = await StorageService.getToken();
      const url = '${AppConfig.baseUrl}/fishindo/delete';
      _logger.i('📡 GET (with trashed): $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.d('🔹 Status: ${response.statusCode}');
      _logger.d('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'];
      } else {
        throw Exception("Gagal mengambil data fishindo (dihapus)");
      }
    } catch (e, s) {
      _logger.e("❌ Error getAllWithTrashed", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ✅ Ambil 1 data maintenance berdasarkan ID
  Future<Map<String, dynamic>> getById(int id) async {
    try {
      final token = await StorageService.getToken();
      final url = '${AppConfig.baseUrl}/fishindo/$id';
      _logger.i('📡 GET by ID: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.d('🔹 Status: ${response.statusCode}');
      _logger.d('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'];
      } else {
        throw Exception("Gagal mengambil data Fishindo dengan ID $id");
      }
    } catch (e, s) {
      _logger.e("❌ Error getById", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ✅ Buat data maintenance baru
  Future<Map<String, dynamic>> create(
    String lokasi,
    String nelayan,
    double timbangan,
    double harga,
    int jenisikanId,
    List<File> imagesFish,
    List<File> imagesTimbangan,
  ) async {
    final token = await StorageService.getToken();
    final userIdBy = await StorageService.getUserId();

    final uri = Uri.parse('${AppConfig.baseUrl}/fishindo');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'user_id_by': userIdBy.toString(),
      'lokasi': lokasi,
      'nelayan': nelayan,
      'timbangan': timbangan.toString(),
      'harga': harga.toString(),
      'jenisikan_id': jenisikanId.toString(),
    });

    for (final file in imagesFish) {
      request.files.add(
        await http.MultipartFile.fromPath('images_fish[]', file.path),
      );
    }

    for (final file in imagesTimbangan) {
      request.files.add(
        await http.MultipartFile.fromPath('images_timbangan[]', file.path),
      );
    }

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  /// ✅ Update data maintenance (biasa)
  Future<Map<String, dynamic>> update(
    int id,
    int userIdBy,
    int userIdTo,
    String lokasi,
    String nelayan,
    double timbangan,
    double harga,
    int jenisikanId,
  ) async {
    final token = await StorageService.getToken();
    final uri = Uri.parse('${AppConfig.baseUrl}/fishindo/$id');

    final body = jsonEncode({
      "user_id_by": userIdBy,
      "user_id_to": userIdTo,
      "lokasi": lokasi,
      "nelayan": nelayan,
      "timbangan": timbangan,
      "harga": harga,
      "jenisikan_id": jenisikanId,
    });

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      _logger.e('❌ Gagal update Fishindo (${response.statusCode})');
      _logger.e('📦 Body: ${response.body}');
      throw Exception("Failed to update fishindo");
    }
  }

  /// ✅ Hapus sementara (soft delete)
  Future<Map<String, dynamic>> deletesementara(int id) async {
    try {
      final token = await StorageService.getToken();
      final url = '${AppConfig.baseUrl}/fishindo/$id';
      _logger.w('🗑️ DELETE Sementara: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.d('🔹 Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorMessage = jsonDecode(response.body)['error'] ??
            'Terjadi kesalahan saat menghapus data.';
        throw Exception(errorMessage);
      }
    } catch (e, s) {
      _logger.e("❌ Error deletesementara", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ✅ Restore data yang terhapus sementara
  Future<Map<String, dynamic>> restore(int id) async {
    try {
      final token = await StorageService.getToken();
      final url = '${AppConfig.baseUrl}/fishindo/restore/$id';
      _logger.i('♻️ RESTORE: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.d('🔹 Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorMessage = jsonDecode(response.body)['error'] ??
            'Gagal melakukan restore data.';
        throw Exception(errorMessage);
      }
    } catch (e, s) {
      _logger.e("❌ Error restore", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ✅ Hapus permanen (force delete)
  Future<Map<String, dynamic>> forceDelete(int id) async {
    try {
      final token = await StorageService.getToken();
      final url = '${AppConfig.baseUrl}/fishindo/force-delete/$id';
      _logger.w('🚨 FORCE DELETE: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.d('🔹 Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorMessage = jsonDecode(response.body)['error'] ??
            'Gagal melakukan force delete.';
        throw Exception(errorMessage);
      }
    } catch (e, s) {
      _logger.e("❌ Error forceDelete", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// ✅ Export ke Excel
  Future<String?> listFishindoExcel() async {
    try {
      final token = await StorageService.getToken();
      const url = "${AppConfig.baseUrl}/fishindo/export";
      _logger.i('📤 Export Excel: $url');

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = await getExternalStorageDirectories(
                type: StorageDirectory.downloads)
            .then((dirs) => dirs?.first);
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null || !downloadsDir.existsSync()) {
        throw Exception("Gagal menemukan folder Download.");
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final savePath = "${downloadsDir.path}/fishindo_export_$timestamp.xlsx";

      final response = await dio.download(
        url,
        savePath,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      _logger.d('🔹 Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        _logger.i("✅ Download berhasil: $savePath");
        return savePath;
      } else {
        throw Exception("Gagal download file. Status: ${response.statusCode}");
      }
    } catch (e, s) {
      _logger.e("❌ Download Excel error", error: e, stackTrace: s);
      return null;
    }
  }

  Future<List<dynamic>> fetchJenisikan() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/jenisikan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] as List;
      } else if (decoded is List) {
        return decoded;
      } else {
        throw Exception(
            'Invalid response format: Expected List or Map with "data" key');
      }
    } else {
      throw Exception(
          "Failed to load jenisikan (status: ${response.statusCode})");
    }
  }
}

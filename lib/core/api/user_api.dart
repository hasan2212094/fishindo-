import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../../core/config/app_config.dart';
import 'package:logger/logger.dart';

class UserApi {
  final _logger = Logger();

  Future<List<dynamic>> listUsers() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // _logger.d('Login response status: ${response.statusCode}');
    // _logger.d('Login response body: ${response.body}');
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
      throw Exception("Failed to load users (status: ${response.statusCode})");
    }
  }

  Future<Map<String, dynamic>> getUserData(String userId) async {
    int id = int.parse(userId);
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    //_logger.d('user by id: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<Map<String, dynamic>> updateUserData(String userId, String name,
      String email, String password, int roleId) async {
    try {
      int id = int.parse(userId);
      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'password': password,
        'role_id': roleId
      };

      final token = await StorageService.getToken();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );
      _logger.d('user by id: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _logger.e(jsonDecode(response.body));
        final errorMessage = jsonDecode(response.body)['error'] ??
            'Terjadi kesalahan, silahkan hubungi IT.';
        _logger.e('Login failed: $errorMessage');
        return Future.error(errorMessage);
      }
    } catch (e) {
      _logger.e('Error updating user: $e');
      return {
        'success': false,
        'message': 'Error updating user: $e',
      };
    }
  }

  Future<List<dynamic>> fetchRoles() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/roles'),
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
      throw Exception("Failed to load users (status: ${response.statusCode})");
    }
  }

  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      int id = int.parse(userId);

      final token = await StorageService.getToken();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _logger.d('response: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _logger.e(jsonDecode(response.body));
        final errorMessage = jsonDecode(response.body)['error'] ??
            'Terjadi kesalahan, silahkan hubungi IT.';
        _logger.e('Login failed: $errorMessage');
        return Future.error(errorMessage);
      }
    } catch (e) {
      _logger.e('Error delete user: $e');
      return {
        'success': false,
        'message': 'Error delete user: $e',
      };
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import 'package:logger/logger.dart';

class AuthApi {
  final _logger = Logger();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    // _logger.i('Info message');
    // _logger.w('Warning message');
    // _logger.e('Error message');
    // _logger.d('Login response status: ${response.statusCode}');
     _logger.d('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Terjadi kesalahan';
      _logger.e('Login failed: $errorMessage');
      return Future.error(errorMessage);
    }
  }

  
  Future<Map<String, dynamic>> register(String name,String email, String password, int roleId) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name,'email': email, 'password': password, 'role_id': roleId}),
    );
    // _logger.i('Info message');
    // _logger.w('Warning message');
    // _logger.e('Error message');
    // _logger.d('Login response status: ${response.statusCode}');
     _logger.d('register response body: ${response.body}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
       _logger.e(jsonDecode(response.body));
      final errorMessage = jsonDecode(response.body)['error'] ?? 'Terjadi kesalahan, silahkan hubungi IT.';
      _logger.e('Login failed: $errorMessage');
      return Future.error(errorMessage);
    }
  }
}

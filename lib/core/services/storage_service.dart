import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<void> saveUserId(String id) async {
    await _storage.write(key: 'userId', value: id);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }

  static Future<void> clearuserId() async {
    await _storage.delete(key: 'userId');
  }

  static Future<void> saveUserName(String userName) async {
    await _storage.write(key: 'userName', value: userName);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: 'userName');
  }

  static Future<void> clearuserName() async {
    await _storage.delete(key: 'userName');
  }

  static Future<void> saveRoleId(String roleId) async {
    await _storage.write(key: 'roleId', value: roleId);
  }

  static Future<String?> getRoleId() async {
    return await _storage.read(key: 'roleId');
  }

  static Future<void> clearRoleId() async {
    await _storage.delete(key: 'roleId');
  }

  static Future<void> saveRoleName(String roleName) async {
    await _storage.write(key: 'roleName', value: roleName);
  }

  static Future<String?> getRoleName() async {
    return await _storage.read(key: 'roleName');
  }

  static Future<void> clearRoleName() async {
    await _storage.delete(key: 'roleName');
  }
}

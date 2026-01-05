import '../models/auth_model.dart';
import '../../core/api/auth_api.dart';
import '../models/success_model.dart';

class AuthRepository {
  final AuthApi authApi;

  AuthRepository({required this.authApi});

  Future<AuthModel> login(String email, String password) async {
    final response = await authApi.login(email, password);
    return AuthModel.fromJson(response);
  }

  Future<SuccessModel> register(
      String name, String email, String password, int roleId) async {
    final response = await authApi.register(name, email, password, roleId);
    return SuccessModel.fromJson(response);
  }
}

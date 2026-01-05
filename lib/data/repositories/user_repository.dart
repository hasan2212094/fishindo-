import 'package:fishindo_app/data/models/role_model.dart';
import 'package:fishindo_app/data/models/success_model.dart';

import '../models/user_model.dart';
import '../../core/api/user_api.dart';
//import 'package:logger/logger.dart';

class UserRepository {
  final UserApi userApi;

  UserRepository({required this.userApi});

  Future<List<UserModel>> getUsers() async {
    //final logger = Logger();

    final response = await userApi.listUsers();
    //logger.d('Raw user list: $response');

    return response.map<UserModel>((json) => UserModel.fromJson(json)).toList();
  }

  Future<UserModel> getUserById(String userId) async {
    final response = await userApi.getUserData(userId);
    return UserModel.fromJson(response);
  }

  Future<List<RoleModel>> getRoles() async {
    final response = await userApi.fetchRoles();

    return response.map<RoleModel>((json) => RoleModel.fromJson(json)).toList();
  }

  Future<UserModel> editUserById(
    String userId,
    String name,
    String email,
    String password,
    int roleId,
  ) async {
    final response = await userApi.updateUserData(
      userId,
      name,
      email,
      password,
      roleId,
    );
    return UserModel.fromJson(response);
  }

  Future<SuccessModel> deleteUserById(String userId) async {
    final response = await userApi.deleteUser(userId);
    return SuccessModel.fromJson(response);
  }
}

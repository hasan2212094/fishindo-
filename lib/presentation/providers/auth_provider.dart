import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:fishindo_app/data/models/success_model.dart';
import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/api/auth_api.dart';
import '../../core/services/storage_service.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(authApi: AuthApi()),
);

final registerRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(authApi: AuthApi()),
);

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthModel?>>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return AuthNotifier(authRepository);
    });

final registerProvider =
    StateNotifierProvider<RegisterNotifier, AsyncValue<SuccessModel?>>((ref) {
      final registerRepository = ref.read(authRepositoryProvider);
      return RegisterNotifier(registerRepository);
    });

class AuthNotifier extends StateNotifier<AsyncValue<AuthModel?>> {
  final AuthRepository authRepository;

  final _logger = Logger();

  AuthNotifier(this.authRepository) : super(const AsyncValue.data(null));

  AuthModel? get user => state.value;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await authRepository.login(email, password);
      _logger.i(user);
      await StorageService.saveToken(user.token);
      await StorageService.saveUserId(user.id.toString());
      await StorageService.saveUserName(user.name.toString());
      await StorageService.saveRoleName(user.rolename);
      await StorageService.saveRoleId(user.roleid.toString());
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    await StorageService.clearToken();
    await StorageService.clearuserId();
    await StorageService.clearuserName();
    await StorageService.clearRoleId();
    await StorageService.clearRoleName();
    state = const AsyncValue.data(null);
  }
}

class RegisterNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final AuthRepository authRepository;

  RegisterNotifier(this.authRepository) : super(const AsyncValue.data(null));

  SuccessModel? get user => state.value;

  Future<void> register(
    String name,
    String email,
    String password,
    int roleId,
  ) async {
    state = const AsyncValue.loading();
    try {
      final register = await authRepository.register(
        name,
        email,
        password,
        roleId,
      );

      state = AsyncValue.data(register);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

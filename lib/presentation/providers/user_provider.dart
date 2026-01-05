import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/data/models/role_model.dart';
import 'package:fishindo_app/data/models/success_model.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/api/user_api.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(userApi: UserApi()),
);

final userProvider = FutureProvider<List<UserModel>>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getUsers();
});

final userProfileProvider = FutureProvider<UserModel>((ref) async {
  final userId = await StorageService.getUserId();
  final repository = ref.read(userRepositoryProvider);
  return await repository.getUserById(userId.toString());
});

final userIdProvider = FutureProvider.family<UserModel, int>((
  ref,
  userId,
) async {
  final repository = ref.read(userRepositoryProvider);
  return await repository.getUserById(userId.toString());
});

final roleProvider = FutureProvider<List<RoleModel>>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getRoles();
});

final userEditProvider =
    StateNotifierProvider<EditNotifier, AsyncValue<UserModel?>>((ref) {
      final userRepository = ref.read(userRepositoryProvider);
      return EditNotifier(userRepository);
    });

final userDeleteProvider =
    StateNotifierProvider<DeleteNotifier, AsyncValue<SuccessModel?>>((ref) {
      final userRepository = ref.read(userRepositoryProvider);
      return DeleteNotifier(userRepository);
    });

class EditNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final UserRepository userRepository;

  EditNotifier(this.userRepository) : super(const AsyncValue.data(null));

  UserModel? get user => state.value;

  Future<void> update(
    String userId,
    String name,
    String email,
    String password,
    int roleId,
  ) async {
    state = const AsyncValue.loading();
    try {
      final update = await userRepository.editUserById(
        userId,
        name,
        email,
        password,
        roleId,
      );

      state = AsyncValue.data(update);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class DeleteNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final UserRepository userRepository;

  DeleteNotifier(this.userRepository) : super(const AsyncValue.data(null));

  SuccessModel? get user => state.value;

  Future<void> delete(String userId) async {
    state = const AsyncValue.loading();
    try {
      final delete = await userRepository.deleteUserById(userId);

      state = AsyncValue.data(delete);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

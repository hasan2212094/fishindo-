import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/mainbox_model.dart';
import '../../data/models/success_model.dart';
import '/data/repositories/mainbox_repository.dart';
import '/core/api/mainbox_api.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

final mainBoxRepositoryProvider = Provider<MainBoxRepository>((ref) {
  return MainBoxRepository(mainBoxApi: MainBoxApi());
});

final mainBoxAllProvider = FutureProvider<List<MainBoxModel>>((ref) async {
  final repo = ref.read(mainBoxRepositoryProvider);
  return repo.getAll();
});

final mainBoxByIdProvider = FutureProvider.family<MainBoxModel, int>((
  ref,
  id,
) async {
  final repo = ref.read(mainBoxRepositoryProvider);
  return repo.getById(id);
});

final mainBoxCreateProvider =
    StateNotifierProvider<CreateMainBoxNotifier, AsyncValue<SuccessModel?>>((
      ref,
    ) {
      final repo = ref.read(mainBoxRepositoryProvider);
      return CreateMainBoxNotifier(repo, ref);
    });

class CreateMainBoxNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final MainBoxRepository repository;
  final Ref ref;

  CreateMainBoxNotifier(this.repository, this.ref)
    : super(const AsyncValue.data(null));

  Future<void> create(String name) async {
    state = const AsyncValue.loading();
    try {
      await repository.create(name);
      ref.invalidate(mainBoxAllProvider);
      state = AsyncValue.data(SuccessModel(message: 'MainBox created'));
    } catch (e, st) {
      _logger.e("Create MainBox error", error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

final mainBoxUpdateProvider =
    StateNotifierProvider<UpdateMainBoxNotifier, AsyncValue<SuccessModel?>>((
      ref,
    ) {
      final repo = ref.read(mainBoxRepositoryProvider);
      return UpdateMainBoxNotifier(repo, ref);
    });

class UpdateMainBoxNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final MainBoxRepository repository;
  final Ref ref;

  UpdateMainBoxNotifier(this.repository, this.ref)
    : super(const AsyncValue.data(null));

  Future<void> update(int id, String name) async {
    state = const AsyncValue.loading();
    try {
      await repository.update(id, name);
      ref.invalidate(mainBoxAllProvider);
      state = AsyncValue.data(SuccessModel(message: 'MainBox updated'));
    } catch (e, st) {
      _logger.e("Update MainBox error", error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

final mainBoxDeleteProvider =
    StateNotifierProvider<DeleteMainBoxNotifier, AsyncValue<SuccessModel?>>((
      ref,
    ) {
      final repo = ref.read(mainBoxRepositoryProvider);
      return DeleteMainBoxNotifier(repo, ref);
    });

class DeleteMainBoxNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final MainBoxRepository repository;
  final Ref ref;

  DeleteMainBoxNotifier(this.repository, this.ref)
    : super(const AsyncValue.data(null));

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    try {
      await repository.delete(id);
      ref.invalidate(mainBoxAllProvider);
      state = AsyncValue.data(SuccessModel(message: 'MainBox deleted'));
    } catch (e, st) {
      _logger.e("Delete MainBox error", error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

import '../../data/models/success_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/api/ikan_api.dart';
import 'package:fishindo_app/data/models/ikan_model.dart';
import 'package:fishindo_app/data/repositories/ikan_repository.dart';

/// Provider untuk API
final ikanApiProvider = Provider<IkanApi>((ref) => IkanApi());

/// Provider untuk Repository
final ikanRepositoryProvider = Provider<IkanRepository>(
  (ref) => IkanRepository(ref.watch(ikanApiProvider)),
);

/// Provider untuk ambil semua Workorder
final ikanAllProvider = FutureProvider<List<IkanModel>>((ref) async {
  final repo = ref.watch(ikanRepositoryProvider);
  return repo.getAllIkan();
});

/// Provider untuk ambil Workorder berdasarkan ID
final ikanByIdProvider = FutureProvider.family<IkanModel, int>((ref, id) async {
  final repo = ref.watch(ikanRepositoryProvider);
  return repo.getIkanById(id);
});

/// Provider untuk tambah Workorder
final ikanCreateProvider =
    StateNotifierProvider<IkanCreateNotifier, AsyncValue<IkanModel>>((ref) {
      final repository = ref.read(ikanRepositoryProvider);
      return IkanCreateNotifier(repository);
    });

/// Provider untuk edit Workorder
final ikanEditProvider =
    StateNotifierProvider<IkanEditNotifier, AsyncValue<IkanModel?>>((ref) {
      final repository = ref.read(ikanRepositoryProvider);
      return IkanEditNotifier(repository);
    });

/// Provider untuk hapus Workorder
final ikanDeleteProvider =
    StateNotifierProvider<IkanDeleteNotifier, AsyncValue<SuccessModel?>>((ref) {
      final repository = ref.read(ikanRepositoryProvider);
      return IkanDeleteNotifier(repository);
    });

/// ----------------------
/// CREATE
/// ----------------------
class IkanCreateNotifier extends StateNotifier<AsyncValue<IkanModel>> {
  final IkanRepository repository;

  IkanCreateNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> create(String name, int statuskelompok) async {
    try {
      final newIkan = await repository.createIkan(name, statuskelompok);
      state = AsyncValue.data(newIkan);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// ----------------------
/// UPDATE
/// ----------------------
class IkanEditNotifier extends StateNotifier<AsyncValue<IkanModel?>> {
  final IkanRepository repository;

  IkanEditNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> update(int id, String name, int statuskategori) async {
    state = const AsyncValue.loading();
    try {
      final updated = await repository.updateIkan(id, name, statuskategori);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// ----------------------
/// DELETE
/// ----------------------
class IkanDeleteNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final IkanRepository repository;

  IkanDeleteNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    try {
      final delete = await repository.deleteIkan(id);
      state = AsyncValue.data(delete);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

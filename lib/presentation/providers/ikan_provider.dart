import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/success_model.dart';
import '../../data/models/ikan_model.dart';
import '../../core/api/ikan_api.dart';
import '../../data/repositories/ikan_repository.dart';

/// =====================
/// PROVIDER API & REPO
/// =====================
final ikanApiProvider = Provider<IkanApi>((ref) => IkanApi());

final ikanRepositoryProvider = Provider<IkanRepository>((ref) {
  final api = ref.watch(ikanApiProvider);
  return IkanRepository(api);
});

/// =====================
/// FUTURE PROVIDER
/// =====================

/// Ambil semua ikan
final ikanAllProvider = FutureProvider<List<IkanModel>>((ref) async {
  final repo = ref.watch(ikanRepositoryProvider);
  return repo.getAllIkan();
});

/// Ambil ikan berdasarkan ID
final ikanByIdProvider = FutureProvider.family<IkanModel, int>((ref, id) async {
  final repo = ref.watch(ikanRepositoryProvider);
  return repo.getIkanById(id);
});

/// =====================
/// STATE NOTIFIER PROVIDER
/// =====================

/// Tambah ikan
final ikanCreateProvider =
    StateNotifierProvider<IkanCreateNotifier, AsyncValue<IkanModel>>((ref) {
      final repo = ref.read(ikanRepositoryProvider);
      return IkanCreateNotifier(repo);
    });

/// Edit ikan
final ikanEditProvider =
    StateNotifierProvider<IkanEditNotifier, AsyncValue<IkanModel?>>((ref) {
      final repo = ref.read(ikanRepositoryProvider);
      return IkanEditNotifier(repo);
    });

/// Delete ikan
final ikanDeleteProvider =
    StateNotifierProvider<IkanDeleteNotifier, AsyncValue<SuccessModel?>>((ref) {
      final repo = ref.read(ikanRepositoryProvider);
      return IkanDeleteNotifier(repo);
    });

/// =====================
/// STATE NOTIFIERS
/// =====================

/// ---------------------
/// CREATE
/// ---------------------
class IkanCreateNotifier extends StateNotifier<AsyncValue<IkanModel>> {
  final IkanRepository repository;

  IkanCreateNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> create(String name) async {
    state = const AsyncValue.loading();
    try {
      final newIkan = await repository.createIkan(name);
      state = AsyncValue.data(newIkan);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// ---------------------
/// EDIT / UPDATE
/// ---------------------
class IkanEditNotifier extends StateNotifier<AsyncValue<IkanModel?>> {
  final IkanRepository repository;

  IkanEditNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> update(int id, String name) async {
    state = const AsyncValue.loading();
    try {
      final updated = await repository.updateIkan(id, name);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// ---------------------
/// DELETE
/// ---------------------
class IkanDeleteNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final IkanRepository repository;

  IkanDeleteNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> delete(int id) async {
    // Set state ke loading dulu
    state = const AsyncValue.loading();

    try {
      // Coba panggil delete di repository
      final result = await repository.deleteIkan(id);

      // Jika berhasil, update state ke data
      state = AsyncValue.data(result);

      // Optional: log sukses
      print('✅ Delete sukses ID: $id');
    } catch (e, st) {
      // Jika error, update state ke AsyncError
      state = AsyncValue.error(e, st);

      // Log error lengkap ke console
      print('❌ Error delete ikan ID: $id');
      print('Exception: $e');
      print('StackTrace: $st');
    }
  }
}

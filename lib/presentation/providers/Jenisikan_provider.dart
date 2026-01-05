import '../../data/models/success_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/api/jenisikan_api.dart';
import 'package:fishindo_app/data/models/jenisikan_model.dart';
import 'package:fishindo_app/data/repositories/jenisikan_repository.dart';

/// Provider untuk API
final jenisikanApiProvider = Provider<JenisikanApi>((ref) => JenisikanApi());

/// Provider untuk Repository
final jenisikanRepositoryProvider = Provider<JenisikanRepository>(
  (ref) => JenisikanRepository(ref.watch(jenisikanApiProvider)),
);

/// Provider untuk ambil semua Workorder
final jenisikanAllProvider = FutureProvider<List<JenisIkanModel>>((ref) async {
  final repo = ref.watch(jenisikanRepositoryProvider);
  return repo.getAllJenisikan();
});

/// Provider untuk ambil Workorder berdasarkan ID
final jenisikanByIdProvider = FutureProvider.family<JenisIkanModel, int>((
  ref,
  id,
) async {
  final repo = ref.watch(jenisikanRepositoryProvider);
  return repo.getJenisikanById(id);
});

/// Provider untuk tambah Workorder
final jenisikanCreateProvider =
    StateNotifierProvider<JenisikanCreateNotifier, AsyncValue<JenisIkanModel>>((
      ref,
    ) {
      final repository = ref.read(jenisikanRepositoryProvider);
      return JenisikanCreateNotifier(repository);
    });

/// Provider untuk edit Workorder
final jenisikanEditProvider =
    StateNotifierProvider<JenisikanEditNotifier, AsyncValue<JenisIkanModel?>>((
      ref,
    ) {
      final repository = ref.read(jenisikanRepositoryProvider);
      return JenisikanEditNotifier(repository);
    });

/// Provider untuk hapus Workorder
final jenisikanDeleteProvider =
    StateNotifierProvider<JenisikanDeleteNotifier, AsyncValue<SuccessModel?>>((
      ref,
    ) {
      final repository = ref.read(jenisikanRepositoryProvider);
      return JenisikanDeleteNotifier(repository);
    });

/// ----------------------
/// CREATE
/// ----------------------
class JenisikanCreateNotifier
    extends StateNotifier<AsyncValue<JenisIkanModel>> {
  final JenisikanRepository repository;

  JenisikanCreateNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> create(String name) async {
    try {
      final newJenisikan = await repository.createJenisikan(name);
      state = AsyncValue.data(newJenisikan);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// ----------------------
/// UPDATE
/// ----------------------
class JenisikanEditNotifier extends StateNotifier<AsyncValue<JenisIkanModel?>> {
  final JenisikanRepository repository;

  JenisikanEditNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> update(int id, String name) async {
    state = const AsyncValue.loading();
    try {
      final updated = await repository.updateJenisikan(id, name);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// ----------------------
/// DELETE
/// ----------------------
class JenisikanDeleteNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final JenisikanRepository repository;

  JenisikanDeleteNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    try {
      final delete = await repository.deleteJenisikan(id);
      state = AsyncValue.data(delete);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

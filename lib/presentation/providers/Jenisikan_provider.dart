import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/api/jenisikan_api.dart';
import 'package:fishindo_app/data/models/jenisikan_model.dart';
import 'package:fishindo_app/data/models/ikan_model.dart';
import 'package:fishindo_app/data/models/success_model.dart';
import 'package:fishindo_app/data/repositories/jenisikan_repository.dart';

/// =======================
/// API & REPOSITORY
/// =======================
final jenisikanApiProvider = Provider<JenisikanApi>((ref) {
  return JenisikanApi();
});

final jenisikanRepositoryProvider = Provider<JenisikanRepository>((ref) {
  return JenisikanRepository(jenisikanApi: ref.watch(jenisikanApiProvider));
});

/// =======================
/// DATA JENIS IKAN
/// =======================

/// Semua jenis ikan
final jenisikanAllProvider = FutureProvider<List<JenisIkanModel>>((ref) async {
  final repo = ref.watch(jenisikanRepositoryProvider);
  return repo.getJenisikanAll();
});

/// Jenis ikan by ID
final jenisikanByIdProvider = FutureProvider.family<JenisIkanModel, int>((
  ref,
  id,
) async {
  final repo = ref.watch(jenisikanRepositoryProvider);
  return repo.getById(id);
});

/// =======================
/// IKAN (DROPDOWN / MASTER)
/// =======================

/// Semua ikan (dipakai dropdown create/edit)
final jenisikanIkanProvider = FutureProvider<List<IkanModel>>((ref) async {
  final repo = ref.watch(jenisikanRepositoryProvider);
  return repo.getIkan();
});

/// =======================
/// 🔥 IKAN UTAMA (HOME)
/// =======================
final mainJenisIkanProvider = FutureProvider<List<IkanModel>>((ref) async {
  final repo = ref.watch(jenisikanRepositoryProvider);
  return repo.getIkan();
});

/// =======================
/// 🔥 JENIS IKAN BY IKAN ID (HOME)
/// =======================
final jenisikanByIkanProvider =
    FutureProvider.family<List<JenisIkanModel>, int>((ref, ikanId) async {
      final repo = ref.watch(jenisikanRepositoryProvider);
      return repo.getJenisikanByIkan(ikanId);
    });

/// =======================
/// CRUD
/// =======================

final jenisikanCreateProvider =
    StateNotifierProvider<JenisikanCreateNotifier, AsyncValue<SuccessModel>>(
      (ref) => JenisikanCreateNotifier(ref.read(jenisikanRepositoryProvider)),
    );

final jenisikanEditProvider =
    StateNotifierProvider<JenisikanEditNotifier, AsyncValue<SuccessModel>>(
      (ref) => JenisikanEditNotifier(ref.read(jenisikanRepositoryProvider)),
    );

final jenisikanDeleteProvider =
    StateNotifierProvider<JenisikanDeleteNotifier, AsyncValue<SuccessModel>>(
      (ref) => JenisikanDeleteNotifier(ref.read(jenisikanRepositoryProvider)),
    );

/// =======================
/// NOTIFIER CREATE
/// =======================
class JenisikanCreateNotifier extends StateNotifier<AsyncValue<SuccessModel>> {
  final JenisikanRepository repository;

  JenisikanCreateNotifier(this.repository)
    : super(AsyncValue.data(SuccessModel(message: '')));

  Future<void> create(String name, int ikanId) async {
    state = const AsyncValue.loading();
    try {
      final result = await repository.create(name, ikanId);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// =======================
/// NOTIFIER EDIT
/// =======================
class JenisikanEditNotifier extends StateNotifier<AsyncValue<SuccessModel>> {
  final JenisikanRepository repository;

  JenisikanEditNotifier(this.repository)
    : super(AsyncValue.data(SuccessModel(message: '')));

  Future<void> update(int id, String name, int ikanId) async {
    state = const AsyncValue.loading();
    try {
      final result = await repository.update(id, name, ikanId);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// =======================
/// NOTIFIER DELETE
/// =======================
class JenisikanDeleteNotifier extends StateNotifier<AsyncValue<SuccessModel>> {
  final JenisikanRepository repository;

  JenisikanDeleteNotifier(this.repository)
    : super(AsyncValue.data(SuccessModel(message: '')));

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    try {
      final result = await repository.delete(id);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

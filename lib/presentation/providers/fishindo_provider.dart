// import 'dart:io';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:logger/logger.dart';
// import 'package:sis_task_app/core/api/fishindo_api.dart';
// import 'package:sis_task_app/data/models/fishindo_model.dart';
// import 'package:sis_task_app/data/repositories/fishindo_repository.dart';
// import 'package:sis_task_app/data/models/jenisikan_model.dart';
// import 'package:sis_task_app/data/models/success_model.dart';
// import '../../core/services/storage_service.dart';

// final _logger = Logger();

// /// Repository provider
// final fishindoRepositoryProvider = Provider<FishindoRepository>(
//   (ref) => FishindoRepository(fishindoApi: FishindoApi()),
// );

// /// Get all Fishindo
// final fishindoAllProvider = FutureProvider<List<FishindoModel>>((ref) async {
//   final repository = ref.read(fishindoRepositoryProvider);
//   return repository.getFishindoAll();
// });

// /// Get Fishindo by ID
// final fishindoIdProvider =
//     FutureProvider.family<FishindoModel, int>((ref, id) async {
//   final repository = ref.read(fishindoRepositoryProvider);
//   return await repository.getById(id);
// });

// /// Create Fishindo
// final fishindoCreateProvider =
//     StateNotifierProvider<CreateNotifier, AsyncValue<SuccessModel?>>((ref) {
//   final repository = ref.read(fishindoRepositoryProvider);
//   return CreateNotifier(ref, repository);
// });

// /// Update Fishindo
// final fishindoUpdateProvider =
//     StateNotifierProvider<UpdateNotifier, AsyncValue<SuccessModel?>>((ref) {
//   final repository = ref.read(fishindoRepositoryProvider);
//   return UpdateNotifier(repository);
// });

// /// Delete Fishindo
// final fishindoDeleteProvider =
//     StateNotifierProvider<DeleteNotifier, AsyncValue<SuccessModel?>>((ref) {
//   final repository = ref.read(fishindoRepositoryProvider);
//   return DeleteNotifier(repository);
// });

// /// Export Fishindo to Excel
// final fishindoExportProvider =
//     StateNotifierProvider<ExportNotifier, AsyncValue<String?>>((ref) {
//   final repository = ref.read(fishindoRepositoryProvider);
//   return ExportNotifier(repository);
// });

// final jenisikanAllProvider = FutureProvider<List<JenisIkanModel>>((ref) async {
//   final repository = ref.read(fishindoRepositoryProvider);
//   return repository.getJenisikan();
// });

// /// Create Notifier
// class CreateNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
//   final Ref ref;
//   final FishindoRepository repository;
//   CreateNotifier(this.ref, this.repository)
//       : super(const AsyncValue.data(null));

//   Future<void> create(
//     int userIdTo,
//     String lokasi,
//     String nelayan,
//     double timbangan,
//     double harga,
//     int jenisikanId,
//     List<File> images_fish,
//     List<File> images_timbangan,
//   ) async {
//     state = const AsyncValue.loading();

//     try {
//       final userIdBy = await StorageService.getUserId();
//       if (userIdBy == null) {
//         throw Exception("User ID not found");
//       }

//       final result = await repository.create(
//         userIdTo,
//         lokasi,
//         nelayan,
//         timbangan,
//         harga,
//         jenisikanId,
//         images_fish,
//         images_timbangan,
//       );
//       state = AsyncValue.data(result);
//     } catch (e, st) {
//       _logger.e("Create fishindo error", error: e, stackTrace: st);
//       state = AsyncValue.error(e, st);
//     }
//   }
// }

// /// Update notifier
// class UpdateNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
//   final FishindoRepository fishindoRepository;
//   UpdateNotifier(this.fishindoRepository) : super(const AsyncValue.data(null));

//   Future<void> update(
//     int id,
//     String lokasi,
//     String nelayan,
//     double timbangan,
//     double harga,
//     int jenisikanId,
//   ) async {
//     state = const AsyncValue.loading();
//     try {
//       final update = await fishindoRepository.update(
//         id,
//         lokasi,
//         nelayan,
//         timbangan,
//         harga,
//         jenisikanId,
//       );
//       state = AsyncValue.data(update);
//     } catch (e, st) {
//       _logger.e("Update electrical error", error: e, stackTrace: st);
//       state = AsyncValue.error(e, st);
//     }
//   }
// }

// /// Delete notifier
// class DeleteNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
//   final FishindoRepository electricalRepository;

//   DeleteNotifier(this.electricalRepository)
//       : super(const AsyncValue.data(null));

//   Future<void> delete(int id) async {
//     state = const AsyncValue.loading();
//     try {
//       final result = await electricalRepository.delete(id);
//       state = AsyncValue.data(result);
//     } catch (e, st) {
//       _logger.e("Delete error", error: e, stackTrace: st);
//       state = AsyncValue.error(e, st);
//     }
//   }
// }

// /// Export notifier
// class ExportNotifier extends StateNotifier<AsyncValue<String?>> {
//   final FishindoRepository electricalRepository;

//   ExportNotifier(this.electricalRepository)
//       : super(const AsyncValue.data(null));

//   Future<void> export() async {
//     state = const AsyncValue.loading();
//     try {
//       final path = await electricalRepository.downloadExcel();
//       state = AsyncValue.data(path);
//     } catch (e, st) {
//       _logger.e("Export error", error: e, stackTrace: st);
//       state = AsyncValue.error(e, st);
//     }
//   }
// }
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:fishindo_app/core/api/fishindo_api.dart';
import 'package:fishindo_app/data/models/fishindo_model.dart';
import 'package:fishindo_app/data/models/jenisikan_model.dart';
import 'package:fishindo_app/data/models/success_model.dart';
import 'package:fishindo_app/data/repositories/fishindo_repository.dart';
import 'package:fishindo_app/data/repositories/jenisikan_repository.dart';
import 'package:fishindo_app/core/services/storage_service.dart';
import 'package:fishindo_app/presentation/providers/jenisikan_provider.dart';

final _logger = Logger();

/// =======================
/// REPOSITORY PROVIDER
/// =======================
final fishindoRepositoryProvider = Provider<FishindoRepository>(
  (ref) => FishindoRepository(fishindoApi: FishindoApi()),
);

/// =======================
/// GET ALL FISHINDO
/// =======================
final fishindoAllProvider = FutureProvider<List<FishindoModel>>((ref) async {
  final repository = ref.read(fishindoRepositoryProvider);
  return repository.getFishindoAll();
});

final fishindoListProvider = FutureProvider.family<List<FishindoModel>, int?>((
  ref,
  jenisIkanId,
) async {
  final repo = ref.read(fishindoRepositoryProvider);

  if (jenisIkanId == null || jenisIkanId == 0) {
    return repo.getFishindoAll();
  } else {
    return repo.getFishindoByJenis(jenisIkanId);
  }
});

/// =======================
/// GET FISHINDO BY ID
/// =======================
final fishindoIdProvider = FutureProvider.family<FishindoModel, int>((
  ref,
  id,
) async {
  final repository = ref.read(fishindoRepositoryProvider);
  return repository.getById(id);
});

/// =======================
/// GET JENIS IKAN
/// =======================
final JenisfishindoAllProvider = FutureProvider<List<JenisIkanModel>>((
  ref,
) async {
  final repository = ref.read(fishindoRepositoryProvider);
  return repository.getJenisikan();
});

/// =======================
/// CREATE FISHINDO
/// =======================
final fishindoCreateProvider =
    StateNotifierProvider<CreateNotifier, AsyncValue<SuccessModel?>>((ref) {
      final repository = ref.read(fishindoRepositoryProvider);
      return CreateNotifier(ref, repository);
    });

class CreateNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final Ref ref;
  final FishindoRepository repository;

  CreateNotifier(this.ref, this.repository)
    : super(const AsyncValue.data(null));

  Future<void> create(
    String lokasi,
    String nelayan,
    double timbangan,
    double harga,
    int jenisikanId,
    List<File> imagesFish,
    List<File> imagesTimbangan,
  ) async {
    state = const AsyncValue.loading();
    try {
      final result = await repository.create(
        lokasi,
        nelayan,
        timbangan,
        harga,
        jenisikanId,
        imagesFish,
        imagesTimbangan,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// =======================
/// UPDATE FISHINDO
/// =======================
final fishindoUpdateProvider =
    StateNotifierProvider<UpdateNotifier, AsyncValue<SuccessModel?>>((ref) {
      final repository = ref.read(fishindoRepositoryProvider);
      return UpdateNotifier(repository);
    });

class UpdateNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final FishindoRepository repository;

  UpdateNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> update(
    int id,
    String lokasi,
    String nelayan,
    double timbangan,
    double harga,
    int jenisikanId,
  ) async {
    state = const AsyncValue.loading();

    try {
      final result = await repository.update(
        id,
        lokasi,
        nelayan,
        timbangan,
        harga,
        jenisikanId,
      );

      state = AsyncValue.data(result);
    } catch (e, st) {
      _logger.e("Update fishindo error", error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

/// =======================
/// DELETE FISHINDO
/// =======================
final fishindoDeleteProvider =
    StateNotifierProvider<DeleteNotifier, AsyncValue<SuccessModel?>>((ref) {
      final repository = ref.read(fishindoRepositoryProvider);
      return DeleteNotifier(repository);
    });

class DeleteNotifier extends StateNotifier<AsyncValue<SuccessModel?>> {
  final FishindoRepository repository;

  DeleteNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();

    try {
      final result = await repository.delete(id);
      state = AsyncValue.data(result);
    } catch (e, st) {
      _logger.e("Delete fishindo error", error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

/// =======================
/// EXPORT EXCEL
/// =======================
final fishindoExportProvider =
    StateNotifierProvider<ExportNotifier, AsyncValue<String?>>((ref) {
      final repository = ref.read(fishindoRepositoryProvider);
      return ExportNotifier(repository);
    });

class ExportNotifier extends StateNotifier<AsyncValue<String?>> {
  final FishindoRepository repository;

  ExportNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> export() async {
    state = const AsyncValue.loading();

    try {
      final path = await repository.downloadExcel();
      state = AsyncValue.data(path);
    } catch (e, st) {
      _logger.e("Export fishindo error", error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

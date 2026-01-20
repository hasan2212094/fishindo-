// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fishindo_app/core/constants/app_colors.dart';
// import 'package:fishindo_app/presentation/pages/jenisikan/jenisikan_view_page.dart';
// import '../../providers/jenisikan_provider.dart';
// import '../home/home_menu.dart';

// class JenisikanListPage extends ConsumerStatefulWidget {
//   const JenisikanListPage({super.key});

//   @override
//   ConsumerState<JenisikanListPage> createState() => _JenisikanListPageState();
// }

// class _JenisikanListPageState extends ConsumerState<JenisikanListPage> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => ref.invalidate(jenisikanAllProvider));
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: AppColors.purple,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );

//     final jenisikan = ref.watch(jenisikanAllProvider);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.purple,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           color: AppColors.white,
//           iconSize: 18,
//           onPressed: () {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const HomeMenuPage(initialIndex: 0),
//               ),
//               (route) => false,
//             );
//           },
//         ),
//         title: const Text(
//           "Jenis Ikan List",
//           style: TextStyle(color: AppColors.white, fontSize: 16),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             color: AppColors.white,
//             iconSize: 18,
//             onPressed: () {
//               ref.invalidate(jenisikanAllProvider);
//             },
//           ),
//         ],
//       ),
//       backgroundColor: AppColors.light,
//       body: Stack(
//         children: [
//           RefreshIndicator(
//             onRefresh: () async {
//               ref.invalidate(jenisikanAllProvider);
//             },
//             child: jenisikan.when(
//               data:
//                   (items) => ListView.builder(
//                     padding: const EdgeInsets.only(
//                       bottom: 60,
//                       left: 16,
//                       right: 16,
//                       top: 16,
//                     ),
//                     itemCount: items.length,
//                     itemBuilder: (context, index) {
//                       final jenisikan = items[index];
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         decoration: BoxDecoration(
//                           color: AppColors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.1),
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: ListTile(
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                           leading: CircleAvatar(
//                             radius: 22,
//                             backgroundColor: AppColors.purple.withOpacity(0.1),
//                             child: ClipOval(
//                               child: Image.asset(
//                                 'assets/animations/ikan.gif',
//                                 width: 36,
//                                 height: 36,
//                                 fit: BoxFit.cover,
//                                 gaplessPlayback: true,
//                               ),
//                             ),
//                           ),
//                           title: Text(
//                             jenisikan.name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.dark,
//                               fontSize: 14,
//                             ),
//                           ),
//                           subtitle: Text(
//                             'ID: ${jenisikan.id}',
//                             style: const TextStyle(
//                               color: AppColors.secondary,
//                               fontSize: 12,
//                             ),
//                           ),
//                           trailing: const Icon(Icons.chevron_right),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder:
//                                     (context) =>
//                                         JenisikanViewPage(id: jenisikan.id),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (error, _) => Center(child: Text("Error: $error")),
//             ),
//           ),
//           if (jenisikan.isRefreshing)
//             const Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: LinearProgressIndicator(),
//             ),
//         ],
//       ),
//       floatingActionButton: Transform.scale(
//         scale: 0.7,
//         child: FloatingActionButton(
//           onPressed: () async {
//             await Navigator.pushNamed(context, "/jenisikanadd");
//             ref.invalidate(jenisikanAllProvider);
//           },
//           backgroundColor: AppColors.purple,
//           foregroundColor: AppColors.white,
//           shape: const CircleBorder(),
//           child: const Icon(Icons.add, size: 20),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/pages/jenisikan/jenisikan_view_page.dart';
import 'package:fishindo_app/data/models/jenisikan_model.dart';
import '../../providers/jenisikan_provider.dart';
import '../home/home_menu.dart';

/// --------------------------
/// PROVIDERS FILTER GLOBAL
/// --------------------------
final isFilterVisibleProvider = StateProvider<bool>((ref) => false);
final filterPelagisProvider = StateProvider<bool>((ref) => false);
final filterDemersalProvider = StateProvider<bool>((ref) => false);

class JenisikanListPage extends ConsumerStatefulWidget {
  const JenisikanListPage({super.key});

  @override
  ConsumerState<JenisikanListPage> createState() => _JenisikanListPageState();
}

class _JenisikanListPageState extends ConsumerState<JenisikanListPage> {
  @override
  void initState() {
    super.initState();
    // Refresh data saat masuk halaman
    Future.microtask(() => ref.invalidate(jenisikanAllProvider));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.purple,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final jenisikanState = ref.watch(jenisikanAllProvider);
    final isFilterVisible = ref.watch(isFilterVisibleProvider);
    final filterPelagis = ref.watch(filterPelagisProvider);
    final filterDemersal = ref.watch(filterDemersalProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.white,
          iconSize: 18,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeMenuPage(initialIndex: 0),
              ),
              (route) => false,
            );
          },
        ),
        title: const Text(
          "Jenis Ikan List",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: AppColors.white,
            onPressed: () => ref.invalidate(jenisikanAllProvider),
          ),
          IconButton(
            icon: Icon(
              isFilterVisible ? Icons.filter_alt_off : Icons.filter_alt,
            ),
            color: AppColors.white,
            onPressed: () {
              ref.read(isFilterVisibleProvider.notifier).state =
                  !isFilterVisible;
            },
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(jenisikanAllProvider),
            child: jenisikanState.when(
              data: (items) {
                final filtered = _applyFilter(
                  items,
                  filterPelagis: filterPelagis,
                  filterDemersal: filterDemersal,
                );

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length + (isFilterVisible ? 1 : 0),
                  itemBuilder: (context, index) {
                    // --------------------------
                    // WIDGET FILTER UI
                    // --------------------------
                    if (isFilterVisible && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            _buildFilterButton(
                              label: "Pelagis",
                              isActive: filterPelagis,
                              onTap: () {
                                ref.read(filterPelagisProvider.notifier).state =
                                    !filterPelagis;
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterButton(
                              label: "Demersal",
                              isActive: filterDemersal,
                              onTap: () {
                                ref
                                    .read(filterDemersalProvider.notifier)
                                    .state = !filterDemersal;
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    final jenisikan =
                        filtered[isFilterVisible ? index - 1 : index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.purple,
                          child: Text(
                            jenisikan.name.isNotEmpty
                                ? jenisikan.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          jenisikan.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID: ${jenisikan.id}',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    jenisikan.statusKelompok == 0
                                        ? Colors.blue
                                        : Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                jenisikan
                                    .statusKelompokString, // 🔹 otomatis dari ikan induk
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      JenisikanViewPage(id: jenisikan.id),
                            ),
                          );
                          ref.invalidate(jenisikanAllProvider);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text("Error: $error")),
            ),
          ),
          if (jenisikanState.isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: Transform.scale(
        scale: 0.7,
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.pushNamed(context, "/jenisikanadd");
            ref.invalidate(jenisikanAllProvider);
          },
          backgroundColor: AppColors.purple,
          foregroundColor: AppColors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 20),
        ),
      ),
    );
  }

  /// --------------------------
  /// FILTER LOGIC
  /// --------------------------
  List<JenisIkanModel> _applyFilter(
    List<JenisIkanModel> items, {
    required bool filterPelagis,
    required bool filterDemersal,
  }) {
    return items.where((jenisikan) {
      final status = jenisikan.ikan?.status_kelompok ?? 0;
      if (filterPelagis && status == 0) return true;
      if (filterDemersal && status == 1) return true;
      if (!filterPelagis && !filterDemersal) return true;
      return false;
    }).toList();
  }

  /// --------------------------
  /// FILTER BUTTON
  /// --------------------------
  Widget _buildFilterButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple : Colors.white,
          border:
              isActive ? null : Border.all(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// --------------------------
  /// JENISIKAN CARD
  /// --------------------------
  Widget _buildJenisikanCard(JenisIkanModel jenisikan) {
    final status = jenisikan.ikan?.status_kelompok ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.purple.withOpacity(0.1),
          child: ClipOval(
            child: Image.asset(
              'assets/animations/ikan.gif',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          jenisikan.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${jenisikan.id}',
              style: const TextStyle(color: AppColors.secondary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status == 0 ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status == 0 ? "PELAGIS" : "DEMERSAL",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JenisikanViewPage(id: jenisikan.id),
            ),
          );
          ref.invalidate(jenisikanAllProvider);
        },
      ),
    );
  }
}

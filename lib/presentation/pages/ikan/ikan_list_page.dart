// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fishindo_app/core/constants/app_colors.dart';
// import 'package:fishindo_app/presentation/pages/ikan/ikan_view_page.dart';
// import '../../providers/ikan_provider.dart';
// import '../home/home_menu.dart';

// class IkanListPage extends ConsumerStatefulWidget {
//   const IkanListPage({super.key});

//   @override
//   ConsumerState<IkanListPage> createState() => _IkanListPageState();
// }

// class _IkanListPageState extends ConsumerState<IkanListPage> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => ref.invalidate(ikanAllProvider));
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: AppColors.purple,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );

//     final ikan = ref.watch(ikanAllProvider);

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
//           "Ikan List",
//           style: TextStyle(color: AppColors.white, fontSize: 16),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             color: AppColors.white,
//             iconSize: 18,
//             onPressed: () {
//               ref.invalidate(ikanAllProvider);
//             },
//           ),
//         ],
//       ),
//       backgroundColor: AppColors.light,
//       body: Stack(
//         children: [
//           RefreshIndicator(
//             onRefresh: () async {
//               ref.invalidate(ikanAllProvider);
//             },
//             child: ikan.when(
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
//                       final ikan = items[index];
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
//                             radius: 18,
//                             backgroundColor: AppColors.purple,
//                             child: Text(
//                               ikan.name.isNotEmpty
//                                   ? ikan.name[0].toUpperCase()
//                                   : '?',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                           title: Text(
//                             ikan.name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.dark,
//                               fontSize: 14,
//                             ),
//                           ),
//                           subtitle: Text(
//                             'ID: ${ikan.id}',
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
//                                 builder: (context) => IkanViewPage(id: ikan.id),
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
//           if (ikan.isRefreshing)
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
//             final result = await Navigator.pushNamed(context, '/ikanadd');
//             if (result == true) {
//               ref.invalidate(ikanAllProvider);
//             }
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
import 'package:fishindo_app/presentation/pages/ikan/ikan_view_page.dart';
import '../../providers/ikan_provider.dart';
import '../home/home_menu.dart';

/// --------------------------
/// PROVIDERS FILTER GLOBAL
/// --------------------------
final isFilterVisibleProvider = StateProvider<bool>((ref) => false);
final filterPelagisProvider = StateProvider<bool>((ref) => false);
final filterDemersalProvider = StateProvider<bool>((ref) => false);

class IkanListPage extends ConsumerStatefulWidget {
  const IkanListPage({super.key});

  @override
  ConsumerState<IkanListPage> createState() => _IkanListPageState();
}

class _IkanListPageState extends ConsumerState<IkanListPage> {
  @override
  void initState() {
    super.initState();
    // Refresh data saat masuk halaman
    Future.microtask(() => ref.invalidate(ikanAllProvider));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.purple,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Ambil state dari provider
    final ikanState = ref.watch(ikanAllProvider);
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
          "Ikan List",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: AppColors.white,
            onPressed: () => ref.invalidate(ikanAllProvider),
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
            onRefresh: () async => ref.invalidate(ikanAllProvider),
            child: ikanState.when(
              data: (items) {
                // --------------------------
                // LOGIKA FILTER
                // --------------------------
                final filtered =
                    items.where((ikan) {
                      if (filterPelagis && ikan.status_kelompok == 0)
                        return true;
                      if (filterDemersal && ikan.status_kelompok == 1)
                        return true;
                      if (!filterPelagis && !filterDemersal) return true;
                      return false;
                    }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 60,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  itemCount: filtered.length + (isFilterVisible ? 1 : 0),
                  itemBuilder: (context, index) {
                    // --------------------------
                    // WIDGET FILTER UI
                    // --------------------------
                    if (isFilterVisible && index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildFilterButton(
                                label: "Pelagis",
                                isActive: filterPelagis,
                                onTap: () {
                                  ref
                                      .read(filterPelagisProvider.notifier)
                                      .state = !filterPelagis;
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
                          const SizedBox(height: 16),
                        ],
                      );
                    }

                    final ikan = filtered[isFilterVisible ? index - 1 : index];

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
                            ikan.name.isNotEmpty
                                ? ikan.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          ikan.name,
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
                              'ID: ${ikan.id}',
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
                                    ikan.status_kelompok == 0
                                        ? Colors.blue
                                        : Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ikan.status_kelompok == 0
                                    ? "PELAGIS"
                                    : "DEMERSAL",
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
                              builder: (context) => IkanViewPage(id: ikan.id),
                            ),
                          );
                          ref.invalidate(ikanAllProvider);
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
          if (ikanState.isRefreshing)
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
            await Navigator.pushNamed(context, "/ikanadd");
            ref.invalidate(ikanAllProvider);
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
  /// BUTTON FILTER
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
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

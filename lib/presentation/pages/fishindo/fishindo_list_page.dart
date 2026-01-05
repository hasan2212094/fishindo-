import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/fishindo_provider.dart';
import '../home/home_menu.dart';
import 'fishindo_view_page.dart';

class FishindoListPage extends ConsumerStatefulWidget {
  final int? jenisIkanId;

  const FishindoListPage({
    super.key,
    this.jenisIkanId,
  });

  @override
  ConsumerState<FishindoListPage> createState() => _FishindoListPageState();
}

/// local state (auto dispose)
final isFilterVisibleProvider = StateProvider.autoDispose<bool>((ref) => false);
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class _FishindoListPageState extends ConsumerState<FishindoListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.invalidate(fishindoAllProvider));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.purple,
      statusBarIconBrightness: Brightness.light,
    ));

    final fishindoState = ref.watch(fishindoAllProvider);
    final isFilterVisible = ref.watch(isFilterVisibleProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 31, 57, 78),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 18),
          color: AppColors.white,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeMenuPage(initialIndex: 0),
              ),
              (_) => false,
            );
          },
        ),
        title: const Text(
          "Fishindo List",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: AppColors.white,
            onPressed: () => ref.invalidate(fishindoAllProvider),
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

          /// EXPORT EXCEL
          Consumer(
            builder: (_, ref, __) {
              final exportState = ref.watch(fishindoExportProvider);
              return IconButton(
                icon: Icon(
                  Icons.file_download,
                  color:
                      exportState.isLoading ? Colors.grey[300] : Colors.white,
                ),
                onPressed: exportState.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(fishindoExportProvider.notifier)
                            .export();

                        final path =
                            ref.read(fishindoExportProvider).value ?? "";

                        if (!context.mounted) return;

                        if (path.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Download berhasil\n$path"),
                              action: SnackBarAction(
                                label: "OPEN",
                                onPressed: () => OpenFilex.open(path),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Download gagal"),
                            ),
                          );
                        }
                      },
              );
            },
          ),
        ],
      ),

      /// ================= BODY =================
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(fishindoAllProvider),
            child: fishindoState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
              data: (fishindos) {
                /// ===== SEARCH FILTER =====
                final lowerQuery = searchQuery.toLowerCase();
                final filtered = fishindos.where((f) {
                  return (f.jenisikan?.name
                              .toLowerCase()
                              .contains(lowerQuery) ??
                          false) ||
                      f.lokasi.toLowerCase().contains(lowerQuery) ||
                      f.nelayan.toLowerCase().contains(lowerQuery) ||
                      f.userByName.toLowerCase().contains(lowerQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length + (isFilterVisible ? 1 : 0),
                  itemBuilder: (context, index) {
                    /// SEARCH BAR
                    if (isFilterVisible && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          onChanged: (v) =>
                              ref.read(searchQueryProvider.notifier).state = v,
                          decoration: InputDecoration(
                            hintText: "Search...",
                            prefixIcon: const Icon(Icons.search, size: 16),
                            filled: true,
                            fillColor: Colors.white,
                            constraints: const BoxConstraints(maxHeight: 36),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }

                    final fishindo =
                        filtered[isFilterVisible ? index - 1 : index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        title: Text(
                          fishindo.jenisikan?.name ?? "-",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            _info("Lokasi", fishindo.lokasi),
                            _info("Nelayan", fishindo.nelayan),
                            _info("Petugas", fishindo.userByName),
                            _info(
                              "Date",
                              fishindo.createdAt != null
                                  ? DateFormat('dd MMM yyyy')
                                      .format(fishindo.createdAt!)
                                  : "-",
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FishindoViewPage(fishindoId: fishindo.id),
                            ),
                          );
                          ref.invalidate(fishindoAllProvider);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (fishindoState.isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),

      /// ADD BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.purple,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.pushNamed(context, "/fishindoadd");
          ref.invalidate(fishindoAllProvider);
        },
      ),
    );
  }

  Widget _info(String label, String value) {
    return Text(
      "$label : ${value.isNotEmpty ? value : '-'}",
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.secondary,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/jenisikan_provider.dart';
import '../../providers/fishindo_provider.dart';
import '../fishindo/fishindo_list_page.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';

class FishindoListByTypePage extends ConsumerWidget {
  final String jenisIkanName;
  const FishindoListByTypePage({super.key, required this.jenisIkanName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jenisikanState = ref.watch(jenisikanAllProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        title: Text(jenisIkanName, style: const TextStyle(color: Colors.white)),
      ),
      body: jenisikanState.when(
        data: (items) {
          // Ambil ID jenis ikan sesuai nama
          final jenisItems =
              items
                  .where((e) => e.name.toUpperCase().contains(jenisIkanName))
                  .toList();

          if (jenisItems.isEmpty) {
            return const Center(child: Text("Tidak ada data"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemCount: jenisItems.length,
            itemBuilder: (context, index) {
              final ikan = jenisItems[index];

              final fishListAsync = ref.watch(fishindoListProvider(ikan.id));

              double totalBerat = 0;
              double totalHarga = 0;

              fishListAsync.whenData((list) {
                totalBerat = list.fold(0, (sum, item) => sum + item.timbangan);
                totalHarga = list.fold(0, (sum, item) => sum + item.harga);
              });

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FishindoListPage(jenisIkanId: ikan.id),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ikan.name.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      const Text("Total berat", style: TextStyle(fontSize: 10)),
                      Text(
                        "${totalBerat.toStringAsFixed(2)} Kg",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text("Total harga", style: TextStyle(fontSize: 10)),
                      Text(
                        "Rp ${totalHarga.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

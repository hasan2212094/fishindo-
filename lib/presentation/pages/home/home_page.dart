import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fishindo_app/core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../fishindo/fishindo_list_page.dart';
import '../../providers/jenisikan_provider.dart';
import '../../providers/fishindo_provider.dart';
import '../../pages/fishindo/fishindo_list_by_type_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 20) return 'Good Evening';
    return 'Good Night';
  }

  String getFormattedDate() {
    return DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 31, 57, 78),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    Future.microtask(() => ref.invalidate(userProfileProvider));
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final jenisikanState = ref.watch(jenisikanAllProvider);
    final mainIkanAsync = ref.watch(mainJenisIkanProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.light,
        body: RefreshIndicator(
          onRefresh: () async {
            // 🔥 Refresh semua provider terkait
            ref.invalidate(jenisikanAllProvider);

            final jenisikanItems = await ref.read(jenisikanAllProvider.future);
            for (var ikan in jenisikanItems) {
              ref.invalidate(fishindoListProvider(ikan.id));
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== HEADER =====
                userProfile.when(
                  data:
                      (user) => _buildHeader(
                        getGreeting(),
                        getFormattedDate(),
                        user.name,
                        user.rolename,
                      ),
                  loading:
                      () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (error, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          error.toString(),
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                ),

                /// ===== HOME BUTTONS UTAMA =====
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: mainIkanAsync.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (e, _) => Text(
                          e.toString(),
                          style: const TextStyle(color: AppColors.danger),
                        ),
                    data: (items) {
                      return Column(
                        children:
                            items.map((ikan) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(60),
                                    backgroundColor: AppColors.purple,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => FishindoListByTypePage(
                                              jenisIkanName:
                                                  ikan.name, // 🔥 dari database
                                            ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    ikan.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ),

                /// ===== HOME MENU LAMA (GRIDVIEW / SUMMARY) =====
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Home Page Lama",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      jenisikanState.when(
                        data: (items) {
                          // 🔹 Filter ikan utama dulu
                          final mainIkanNames = ['KERAPU', 'TENGGIRI', 'KAKAP'];
                          final mainItems =
                              items
                                  .where(
                                    (ikan) => mainIkanNames.contains(
                                      ikan.name.toUpperCase(),
                                    ),
                                  )
                                  .toList();

                          // 🔹 Ikan baru tambahan
                          final otherItems =
                              items
                                  .where(
                                    (ikan) =>
                                        !mainIkanNames.contains(
                                          ikan.name.toUpperCase(),
                                        ),
                                  )
                                  .toList();

                          final displayItems = [...mainItems, ...otherItems];

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.25,
                                ),
                            itemCount: displayItems.length,
                            itemBuilder: (context, index) {
                              final ikan = displayItems[index];

                              final fishListAsync = ref.watch(
                                fishindoListProvider(ikan.id),
                              );

                              double totalBerat = 0;
                              double totalHarga = 0;

                              fishListAsync.whenData((list) {
                                totalBerat = list.fold(
                                  0,
                                  (sum, item) => sum + item.timbangan,
                                );
                                totalHarga = list.fold(
                                  0,
                                  (sum, item) => sum + item.harga,
                                );
                              });

                              return _fishBox(
                                context,
                                title: ikan.name.toUpperCase(),
                                berat: "${totalBerat.toStringAsFixed(2)} Kg",
                                harga: "Rp ${totalHarga.toStringAsFixed(0)}",
                                jenisIkanId: ikan.id,
                              );
                            },
                          );
                        },
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (e, _) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                "Error: $e",
                                style: const TextStyle(color: AppColors.danger),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ===== BOX IKAN =====
  Widget _fishBox(
    BuildContext context, {
    required String title,
    required String berat,
    required String harga,
    required int jenisIkanId,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FishindoListPage(jenisIkanId: jenisIkanId),
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
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Spacer(),
            const Text("Total berat", style: TextStyle(fontSize: 10)),
            Text(
              berat,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 6),
            const Text("Total harga", style: TextStyle(fontSize: 10)),
            Text(
              harga,
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
  }
}

/// ===== HEADER =====
Widget _buildHeader(
  String greeting,
  String formattedDate,
  String name,
  String rolename,
) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: Color.fromARGB(255, 31, 57, 78),
      border: Border(bottom: BorderSide(width: 10, color: AppColors.warning)),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
            const CircleAvatar(
              backgroundImage: AssetImage("assets/icon/icon_sis.png"),
              radius: 15,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.light,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to',
                        style: TextStyle(fontSize: 10, color: AppColors.dark),
                      ),
                      const Text(
                        'FISHINDO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hi $name ($rolename)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/image/illustration.png',
                width: 90,
                height: 90,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

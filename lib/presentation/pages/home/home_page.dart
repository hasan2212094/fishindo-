import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:fishindo_app/core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../fishindo/fishindo_list_page.dart';

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.light,
        body: SingleChildScrollView(
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

              /// ===== HOME MENU =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Home Menu",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                      children: [
                        _fishBox(
                          context,
                          title: "IKAN KAKAP",
                          berat: "120 Kg",
                          harga: "Rp 12.000.000",
                          jenisIkanId: 1,
                        ),
                        _fishBox(
                          context,
                          title: "IKAN TENGGIRI",
                          berat: "90 Kg",
                          harga: "Rp 10.500.000",
                          jenisIkanId: 2,
                        ),
                        _fishBox(
                          context,
                          title: "IKAN KERAPU",
                          berat: "60 Kg",
                          harga: "Rp 9.000.000",
                          jenisIkanId: 3,
                        ),
                        _fishBox(
                          context,
                          title: "IKAN LAINNYA",
                          berat: "40 Kg",
                          harga: "Rp 4.500.000",
                          jenisIkanId: 0, // tampilkan semua
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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

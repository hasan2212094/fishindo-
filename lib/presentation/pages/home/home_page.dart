import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:fishindo_app/core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/jenisikan_provider.dart';
import '../../providers/fishindo_provider.dart';
import '../../providers/ikan_provider.dart';
import '../fishindo/fishindo_list_page.dart';
import '../fishindo/fishindo_list_by_type_page.dart';
import 'package:fishindo_app/data/models/ikan_model.dart';
import 'package:fishindo_app/data/models/jenisikan_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // ================= CONNECTIVITY =================
  late final Connectivity _connectivity;
  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  Color _connectionBarColor = Colors.green;

  void _updateConnectionStatus(ConnectivityResult status) {
    if (_connectionStatus == status) return;

    setState(() {
      _connectionStatus = status;
      _connectionBarColor =
          status == ConnectivityResult.none ? Colors.red : Colors.green;
    });

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                status == ConnectivityResult.none
                    ? 'Connection lost'
                    : 'Connection restored',
              ),
              backgroundColor: _connectionBarColor,
              duration: const Duration(seconds: 2),
            ),
          );
      });
    }
  }

  // ================= CACHE =================
  List<IkanModel>? _cachedMainIkan;
  List<JenisIkanModel>? _cachedJenisIkan;

  // ================= GREETING =================
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

    _connectivity = Connectivity();
    _connectivity.checkConnectivity().then(_updateConnectionStatus);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    Future.microtask(() => ref.invalidate(userProfileProvider));
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final jenisikanState = ref.watch(jenisikanAllProvider);
    final mainIkanAsync = ref.watch(ikanAllProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.light,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(jenisikanAllProvider);
                ref.invalidate(mainJenisIkanProvider);
                final items = await ref.read(jenisikanAllProvider.future);
                for (var ikan in items) {
                  ref.invalidate(fishindoListProvider(ikan.id));
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER =====
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
                          (e, _) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              e.toString(),
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ),
                    ),

                    // ===== MAIN IKAN BUTTON =====
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: mainIkanAsync.when(
                        data: (items) {
                          _cachedMainIkan = items;
                          return buildMainIkanButtons(items);
                        },
                        loading:
                            () =>
                                _cachedMainIkan != null
                                    ? buildMainIkanButtons(_cachedMainIkan!)
                                    : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                        error:
                            (e, _) =>
                                _cachedMainIkan != null
                                    ? buildMainIkanButtons(_cachedMainIkan!)
                                    : Text(
                                      e.toString(),
                                      style: const TextStyle(
                                        color: AppColors.danger,
                                      ),
                                    ),
                      ),
                    ),

                    // ===== GRID LAMA =====
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: jenisikanState.when(
                        data: (items) {
                          _cachedJenisIkan = items;
                          return buildGrid(items);
                        },
                        loading:
                            () =>
                                _cachedJenisIkan != null
                                    ? buildGrid(_cachedJenisIkan!)
                                    : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                        error:
                            (e, _) =>
                                _cachedJenisIkan != null
                                    ? buildGrid(_cachedJenisIkan!)
                                    : Text(
                                      e.toString(),
                                      style: const TextStyle(
                                        color: AppColors.danger,
                                      ),
                                    ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== CONNECTION BAR =====
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: _connectionBarColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== MAIN BUTTONS =====
  Widget buildMainIkanButtons(List<IkanModel> items) {
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
                          (_) =>
                              FishindoListByTypePage(jenisIkanName: ikan.name),
                    ),
                  );
                },
                onLongPress: () async {
                  // Tombol long press untuk delete ikan
                  final deleteNotifier = ref.read(ikanDeleteProvider.notifier);
                  try {
                    await deleteNotifier.delete(ikan.id);
                    // Refresh main ikan supaya hilang dari homepage
                    ref.invalidate(mainJenisIkanProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ikan berhasil dihapus')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus ikan: $e')),
                    );
                  }
                },
                child: Text(
                  ikan.name.toUpperCase(),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            );
          }).toList(),
    );
  }

  // ===== GRID =====
  Widget buildGrid(List<JenisIkanModel> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final ikan = items[index];
        final fishListAsync = ref.watch(fishindoListProvider(ikan.id));

        double totalBerat = 0;
        double totalHarga = 0;

        fishListAsync.whenData((list) {
          totalBerat = list.fold(0, (s, i) => s + i.timbangan);
          totalHarga = list.fold(0, (s, i) => s + i.harga);
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
  }

  Widget _fishBox(
    BuildContext context, {
    required String title,
    required String berat,
    required String harga,
    required int jenisIkanId,
  }) {
    return InkWell(
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

// ===== HEADER =====
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
        Text(greeting, style: const TextStyle(color: Colors.white)),
        Text(
          formattedDate,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        const SizedBox(height: 20),
        Text(
          'Hi $name ($rolename)',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/pages/jenisikan/jenisikan_view_page.dart';
import '../../providers/jenisikan_provider.dart';
import '../home/home_menu.dart';

class JenisikanListPage extends ConsumerStatefulWidget {
  const JenisikanListPage({super.key});

  @override
  ConsumerState<JenisikanListPage> createState() => _JenisikanListPageState();
}

class _JenisikanListPageState extends ConsumerState<JenisikanListPage> {
  @override
  void initState() {
    super.initState();
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

    final jenisikan = ref.watch(jenisikanAllProvider);

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
            iconSize: 18,
            onPressed: () {
              ref.invalidate(jenisikanAllProvider);
            },
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(jenisikanAllProvider);
            },
            child: jenisikan.when(
              data:
                  (items) => ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 60,
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final jenisikan = items[index];
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
                            radius: 22,
                            backgroundColor: AppColors.purple.withOpacity(0.1),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/animations/ikan.gif',
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
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
                          subtitle: Text(
                            'ID: ${jenisikan.id}',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        JenisikanViewPage(id: jenisikan.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text("Error: $error")),
            ),
          ),
          if (jenisikan.isRefreshing)
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
}

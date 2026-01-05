import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/pages/fishindo/fishindo_edit_page.dart';
import 'package:fishindo_app/presentation/providers/fishindo_provider.dart';
import 'package:fishindo_app/core/services/storage_service.dart';

class FishindoViewPage extends ConsumerStatefulWidget {
  final int fishindoId;

  const FishindoViewPage({super.key, required this.fishindoId});

  @override
  ConsumerState<FishindoViewPage> createState() => _FishindoViewPageState();
}

class _FishindoViewPageState extends ConsumerState<FishindoViewPage> {
  bool isUserDoneRespond = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final userName = await StorageService.getUserName();
      if (userName != null && userName.toLowerCase().contains('maintenance')) {
        setState(() {
          isUserDoneRespond = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(fishindoIdProvider(widget.fishindoId));
  }

  @override
  Widget build(BuildContext context) {
    final fishindoAsync = ref.watch(fishindoIdProvider(widget.fishindoId));

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FC),
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        title: const Text(
          "Fishindo Detail",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.white,
          iconSize: 18,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          fishindoAsync.when(
            data: (fishindo) {
              final createdAt = fishindo.createdAt ?? DateTime.now();
              final isLessThanOneDay =
                  DateTime.now().difference(createdAt).inHours < 24;

              final showEdit = isUserDoneRespond ? isLessThanOneDay : true;

              return showEdit
                  ? IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.white,
                    iconSize: 18,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FishindoEditPage(id: fishindo.id),
                        ),
                      );
                    },
                  )
                  : const SizedBox();
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: fishindoAsync.when(
        data: (fishindo) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER CARD
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("From : ${fishindo.userByName ?? '-'}"),
                      const SizedBox(height: 6),
                      Text(
                        fishindo.createdAt != null
                            ? 'Date : ${DateFormat('dd MMM yyyy, HH:mm').format(fishindo.createdAt!)}'
                            : 'Date : -',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                /// DETAIL CARD
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fishindo.jenisikan?.name ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text("Lokasi : ${fishindo.lokasi}"),
                      const SizedBox(height: 4),
                      Text("Nelayan : ${fishindo.nelayan}"),
                      const SizedBox(height: 4),
                      Text(
                        "Timbangan : ${fishindo.timbangan.toStringAsFixed(2)} Kg",
                      ),
                      const SizedBox(height: 4),
                      Text("Harga : Rp ${fishindo.harga.toStringAsFixed(0)}"),
                      const SizedBox(height: 12),

                      /// IMAGES FISH
                      if (fishindo.imagesFish.isNotEmpty)
                        _buildImageSection(
                          title: "Foto Ikan",
                          images: fishindo.imagesFish,
                        ),

                      /// IMAGES TIMBANGAN
                      if (fishindo.imagesTimbangan.isNotEmpty)
                        _buildImageSection(
                          title: "Foto Timbangan",
                          images: fishindo.imagesTimbangan,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  /// CARD CONTAINER
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// IMAGE SECTION
  Widget _buildImageSection({
    required String title,
    required List<String> images,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              images.map((url) {
                return GestureDetector(
                  onTap: () => _openImagePreview(context, url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const CircularProgressIndicator(),
                      errorWidget:
                          (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// IMAGE PREVIEW
  void _openImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.network(imageUrl),
            ),
          ),
    );
  }
}

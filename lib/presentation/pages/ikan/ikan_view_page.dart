import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/providers/ikan_provider.dart';
import 'package:fishindo_app/presentation/pages/ikan/ikan_edit_page.dart';
import 'package:fishindo_app/data/models/success_model.dart';

class IkanViewPage extends ConsumerStatefulWidget {
  final int id;
  const IkanViewPage({super.key, required this.id});

  @override
  ConsumerState<IkanViewPage> createState() => _IkanViewPageState();
}

class _IkanViewPageState extends ConsumerState<IkanViewPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data setiap kali halaman dibuka
    ref.invalidate(ikanByIdProvider(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final ikanAsync = ref.watch(ikanByIdProvider(widget.id));
    final deleteState = ref.watch(ikanDeleteProvider);

    // Fungsi delete
    Future<void> deleteIkan() async {
      try {
        await ref.read(ikanDeleteProvider.notifier).delete(widget.id);
      } catch (e) {
        debugPrint("❌ Error deleting ikan: $e");
      }
    }

    // ===== LISTENER SAFE =====
    ref.listen<AsyncValue<SuccessModel?>>(ikanDeleteProvider, (previous, next) {
      next.when(
        data: (value) {
          if (value != null && context.mounted) {
            // Invalidate mainJenisIkanProvider supaya homepage auto update
            ref.invalidate(ikanAllProvider);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Success", textAlign: TextAlign.center),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Ikan removed successfully!",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, "/ikan");
                          },
                          child: const Text("Back to list"),
                        ),
                      ],
                    ),
              );
            });
          }
        },
        loading: () {},
        error: (err, st) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error deleting ikan: $err")),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ikan View",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          // Tombol delete
          IconButton(
            icon: const Icon(Icons.delete),
            color: AppColors.danger,
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Confirm Delete"),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      content: const Text(
                        "Are you sure you want to remove this Ikan?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            deleteIkan();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                          ),
                          child: const Text(
                            "Yes, Remove!",
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),

          // Tombol edit
          IconButton(
            icon: const Icon(Icons.edit),
            color: AppColors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IkanEditPage(id: widget.id),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: ikanAsync.when(
        data: (ikan) {
          if (idController.text.isEmpty) idController.text = ikan.id.toString();
          if (nameController.text.isEmpty)
            nameController.text = ikan.name ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (deleteState.isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (deleteState.hasError)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Error: ${deleteState.error}",
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  TextFormField(
                    controller: idController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'ID',
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.dark,
                      ),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Divider(thickness: 0.5),
                  TextFormField(
                    controller: nameController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Name Ikan',
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.dark,
                      ),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Divider(thickness: 0.5),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error loading ikan: $err")),
      ),
    );
  }
}

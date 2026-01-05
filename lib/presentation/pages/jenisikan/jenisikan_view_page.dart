import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/providers/jenisikan_provider.dart';
import 'package:fishindo_app/presentation/pages/jenisikan/jenisikan_edit_page.dart';

class JenisikanViewPage extends ConsumerStatefulWidget {
  final int id;
  const JenisikanViewPage({super.key, required this.id});

  @override
  ConsumerState<JenisikanViewPage> createState() => _JenisikanViewPageState();
}

class _JenisikanViewPageState extends ConsumerState<JenisikanViewPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // refresh data setiap kali halaman dibuka
    ref.invalidate(jenisikanByIdProvider(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final jenisikanAsync = ref.watch(jenisikanByIdProvider(widget.id));
    final deleteState = ref.watch(jenisikanDeleteProvider);

    // Fungsi hapus workorder
    Future<void> deleteJenisikan() async {
      try {
        await ref.read(jenisikanDeleteProvider.notifier).delete(widget.id);
      } catch (e) {
        debugPrint("❌ Error deleting workorder: $e");
      }
    }

    // Listener untuk sukses hapus
    ref.listen(jenisikanDeleteProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        ref.invalidate(jenisikanAllProvider);
        if (!context.mounted) return;

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
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                    SizedBox(height: 8),
                    Text(
                      "Jenisikan removed successfully!",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, "/jenisikan");
                    },
                    child: const Text("Back to list"),
                  ),
                ],
              ),
        );
      }
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
          "Jenis ikan View",
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
                        "Are you sure you want to remove this jenisikan?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: deleteJenisikan,
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
                  builder: (context) => JenisikanEditPage(id: widget.id),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: jenisikanAsync.when(
        data: (jenisikan) {
          if (idController.text.isEmpty) {
            idController.text = jenisikan.id.toString();
            nameController.text = jenisikan.name;
          }

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
                      labelText: 'Jenis ikan',
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.dark,
                      ),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) =>
                Center(child: Text("Error loading jenis ikan: $err")),
      ),
    );
  }
}

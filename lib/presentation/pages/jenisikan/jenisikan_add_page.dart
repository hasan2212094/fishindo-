import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/providers/jenisikan_provider.dart';

class JenisikanAddPage extends ConsumerStatefulWidget {
  const JenisikanAddPage({super.key});

  @override
  ConsumerState<JenisikanAddPage> createState() => _JenisikanAddPageState();
}

class _JenisikanAddPageState extends ConsumerState<JenisikanAddPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk field
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addState = ref.watch(jenisikanCreateProvider);

    /// Fungsi untuk tambah data workorder
    void addJenisikan() async {
      if (_formKey.currentState!.validate()) {
        await ref
            .read(jenisikanCreateProvider.notifier)
            .create(nameController.text);
      }
    }

    /// Listener untuk hasil tambah
    ref.listen(jenisikanCreateProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        // 🔥 CACHE INVALIDATION (INI INTINYA)
        ref.invalidate(jenisikanAllProvider);

        // Optional UX: reset field
        nameController.clear();

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
                      "Jenisikan created successfully!",
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
          iconSize: 18,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Jenisikan",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_reaction_outlined),
            color: AppColors.white,
            iconSize: 20,
            onPressed: addJenisikan,
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (addState.isLoading)
                  Transform.scale(
                    scale: 0.5,
                    child: const CircularProgressIndicator(),
                  ),
                if (addState.hasError)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Error: ${addState.error}",
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Jenis ikan',
                    labelStyle: TextStyle(fontSize: 12, color: AppColors.dark),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 12),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis ikan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const Divider(thickness: 0.5, height: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

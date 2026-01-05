import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/providers/jenisikan_provider.dart';

class JenisikanEditPage extends ConsumerStatefulWidget {
  final int id;
  const JenisikanEditPage({super.key, required this.id});

  @override
  ConsumerState<JenisikanEditPage> createState() => _JenisikanEditPageState();
}

class _JenisikanEditPageState extends ConsumerState<JenisikanEditPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  bool isSuccess = false;

  @override
  void initState() {
    super.initState();

    // invalidate data lama agar fetch ulang
    Future.microtask(() {
      ref.invalidate(jenisikanByIdProvider(widget.id));
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jenisikanAsync = ref.watch(jenisikanByIdProvider(widget.id));
    final editState = ref.watch(jenisikanEditProvider);

    // Fungsi update
    void update() async {
      if (!mounted) return;

      if (_formKey.currentState!.validate()) {
        setState(() {
          isSuccess = false;
        });

        try {
          await ref
              .read(jenisikanEditProvider.notifier)
              .update(widget.id, nameController.text);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
          return;
        }
      }
    }

    // Listener untuk sukses update
    ref.listen(jenisikanEditProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        setState(() {
          isSuccess = true;
        });

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
                      "Jenis ikan updated successfully!",
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
          "Edit Jenis Ikan",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            color: AppColors.white,
            iconSize: 18,
            onPressed: update,
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: jenisikanAsync.when(
        data: (jenisikan) {
          if (nameController.text.isEmpty) {
            nameController.text = jenisikan.name;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    if (editState.isLoading)
                      Transform.scale(
                        scale: 0.5,
                        child: const CircularProgressIndicator(),
                      ),
                    if (editState.hasError)
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
                              "Error: ${editState.error}",
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    // Field Nomor Workorder
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Ikan',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.dark,
                        ),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

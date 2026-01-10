import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/data/models/ikan_model.dart';
import 'package:fishindo_app/data/models/success_model.dart';
import 'package:fishindo_app/presentation/providers/jenisikan_provider.dart';

class JenisikanAddPage extends ConsumerStatefulWidget {
  const JenisikanAddPage({super.key});

  @override
  ConsumerState<JenisikanAddPage> createState() => _JenisikanAddPageState();
}

class _JenisikanAddPageState extends ConsumerState<JenisikanAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  IkanModel? selectedIkan;

  bool isSubmitting = false; // untuk tombol loading

  @override
  Widget build(BuildContext context) {
    final addState = ref.watch(jenisikanCreateProvider);
    final ikanAsync = ref.watch(jenisikanIkanProvider);

    void addJenisikan() async {
      if (_formKey.currentState!.validate() && selectedIkan != null) {
        setState(() => isSubmitting = true);
        await ref
            .read(jenisikanCreateProvider.notifier)
            .create(nameController.text, selectedIkan!.id);
        setState(() => isSubmitting = false);
      } else if (selectedIkan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih ikan terlebih dahulu")),
        );
      }
    }

    // Listener untuk hasil submit
    ref.listen<AsyncValue<SuccessModel>>(jenisikanCreateProvider, (
      previous,
      next,
    ) {
      if (next is AsyncData && next.value != null) {
        ref.invalidate(jenisikanAllProvider);
        nameController.clear();
        selectedIkan = null;

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Success", textAlign: TextAlign.center),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Jenisikan",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon:
                isSubmitting
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.add_reaction_outlined),
            color: AppColors.white,
            onPressed: isSubmitting ? null : addJenisikan,
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field Nama Jenis Ikan
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Jenis ikan',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Jenis ikan tidak boleh kosong'
                              : null,
                ),
                const SizedBox(height: 16),

                // Dropdown Pilih Ikan
                ikanAsync.when(
                  data: (ikans) {
                    if (ikans.isEmpty) {
                      return const Text("Belum ada data ikan");
                    }
                    return DropdownButtonFormField<IkanModel>(
                      value: selectedIkan,
                      decoration: const InputDecoration(
                        labelText: "Pilih Ikan",
                        border: OutlineInputBorder(),
                      ),
                      items:
                          ikans.map((ikan) {
                            return DropdownMenuItem(
                              value: ikan,
                              child: Text(ikan.name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedIkan = value;
                        });
                      },
                      validator:
                          (value) => value == null ? 'Pilih ikan dulu' : null,
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

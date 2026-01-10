import 'package:flutter/material.dart';
import 'package:fishindo_app/data/models/success_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/data/models/ikan_model.dart';
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
  IkanModel? selectedIkan;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Fetch ulang data jenis ikan
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
    final ikanAsync = ref.watch(jenisikanIkanProvider);
    final editState = ref.watch(jenisikanEditProvider);

    void updateJenisikan() async {
      if (_formKey.currentState!.validate() && selectedIkan != null) {
        setState(() => isSubmitting = true);

        await ref
            .read(jenisikanEditProvider.notifier)
            .update(widget.id, nameController.text, selectedIkan!.id);

        setState(() => isSubmitting = false);
      } else if (selectedIkan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih ikan terlebih dahulu")),
        );
      }
    }

    // Listener untuk sukses update
    ref.listen<AsyncValue<SuccessModel>>(jenisikanEditProvider, (
      previous,
      next,
    ) {
      if (next is AsyncData && next.value != null) {
        ref.invalidate(jenisikanAllProvider); // refresh list

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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Jenis Ikan",
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
                    : const Icon(Icons.save),
            color: AppColors.white,
            onPressed: isSubmitting ? null : updateJenisikan,
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: jenisikanAsync.when(
        data: (jenisikan) {
          if (nameController.text.isEmpty) {
            nameController.text = jenisikan.name;
            // bisa set selectedIkan juga kalau ada info ikan_id di model
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    // Nama Jenis Ikan
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Ikan',
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
                        return DropdownButtonFormField<IkanModel>(
                          value: selectedIkan,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Ikan',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              ikans.map((ikan) {
                                return DropdownMenuItem(
                                  value: ikan,
                                  child: Text(ikan.name),
                                );
                              }).toList(),
                          onChanged:
                              (value) => setState(() => selectedIkan = value),
                          validator:
                              (value) =>
                                  value == null ? 'Pilih ikan dulu' : null,
                        );
                      },
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 16),

                    // Error atau Loading State
                    if (editState.isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (editState.hasError)
                      Text(
                        "Error: ${editState.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
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

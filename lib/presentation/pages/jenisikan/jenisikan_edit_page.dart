import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/data/models/ikan_model.dart';
import 'package:fishindo_app/data/models/success_model.dart';
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
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
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

    /// Fungsi update jenis ikan
    void updateJenisikan() async {
      if (isSubmitting) return;

      if (_formKey.currentState!.validate() && selectedIkan != null) {
        setState(() => isSubmitting = true);

        // 🔹 Panggil notifier update → kirim ikan_id
        await ref
            .read(jenisikanEditProvider.notifier)
            .update(
              widget.id,
              nameController.text,
              selectedIkan!.id, // ✅ payload backend aman
            );

        setState(() => isSubmitting = false);
      }
    }

    /// Listener sukses update
    ref.listen<AsyncValue<SuccessModel>>(jenisikanEditProvider, (prev, next) {
      if (prev is AsyncLoading && next is AsyncData) {
        ref.invalidate(jenisikanAllProvider);

        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Success", textAlign: TextAlign.center),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    SizedBox(height: 12),
                    Text("Jenis ikan updated successfully"),
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
        title: const Text(
          "Edit Jenis Ikan",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon:
                isSubmitting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(
                      Icons.save,
                      color: Colors.white,
                    ), // ✅ tombol putih
            onPressed: isSubmitting ? null : updateJenisikan,
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: jenisikanAsync.when(
        data: (jenisikan) {
          if (!isInitialized) {
            nameController.text = jenisikan.name;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  /// Nama Jenis Ikan
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Jenis Ikan",
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? "Tidak boleh kosong"
                                : null,
                  ),
                  const SizedBox(height: 16),

                  /// Dropdown Pilih Ikan
                  ikanAsync.when(
                    data: (ikans) {
                      if (!isInitialized) {
                        selectedIkan = ikans.firstWhere(
                          (i) => i.id == jenisikan.ikan?.id,
                          orElse: () => ikans.first,
                        );
                        isInitialized = true;
                      }

                      return DropdownButtonFormField<IkanModel>(
                        value: selectedIkan,
                        decoration: const InputDecoration(
                          labelText: "Pilih Ikan",
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ikans
                                .map(
                                  (i) => DropdownMenuItem(
                                    value: i,
                                    child: Text(i.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => selectedIkan = v),
                        validator:
                            (v) =>
                                v == null ? "Pilih ikan terlebih dahulu" : null,
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text("Error: $e"),
                  ),

                  /// Loading indicator saat update
                  if (editState.isLoading) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

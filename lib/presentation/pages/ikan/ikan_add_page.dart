import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/providers/ikan_provider.dart';

class IkanAddPage extends ConsumerStatefulWidget {
  const IkanAddPage({super.key});

  @override
  ConsumerState<IkanAddPage> createState() => _IkanAddPageState();
}

class _IkanAddPageState extends ConsumerState<IkanAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addState = ref.watch(ikanCreateProvider);

    // Listener aman di build
    ref.listen<AsyncValue>(ikanCreateProvider, (previous, next) {
      if (next is AsyncData && next.value != null && context.mounted) {
        // Setelah sukses tambah ikan, balik ke homepage
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/', // route homepage
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ikan berhasil ditambahkan!")),
        );
      }
    });

    void addIkan() async {
      if (_formKey.currentState!.validate()) {
        await ref.read(ikanCreateProvider.notifier).create(nameController.text);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Ikan",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.white,
            onPressed: addIkan,
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (addState.isLoading)
                const Center(child: CircularProgressIndicator()),
              if (addState.hasError)
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
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Ikan',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.dark),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 12),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama ikan tidak boleh kosong';
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
  }
}

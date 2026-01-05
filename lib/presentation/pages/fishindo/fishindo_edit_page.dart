import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:fishindo_app/core/config/app_config.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/data/models/jenisikan_model.dart';
import 'package:fishindo_app/presentation/providers/fishindo_provider.dart';
import 'package:fishindo_app/presentation/providers/user_provider.dart';
import '../../../core/services/storage_service.dart';
import 'package:flutter/services.dart';

class FishindoEditPage extends ConsumerStatefulWidget {
  final int id;
  const FishindoEditPage({super.key, required this.id});

  @override
  ConsumerState<FishindoEditPage> createState() => _FishindoEditPageState();
}

class EditableImage {
  final String? url;
  final File? file;

  EditableImage({this.url, this.file});
}

class _FishindoEditPageState extends ConsumerState<FishindoEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _logger = Logger();

  final lokasiController = TextEditingController();
  final nelayanController = TextEditingController();
  final timbanganController = TextEditingController();
  final hargaController = TextEditingController();
  String? _selectedJenisIkan;
  bool isSuccess = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final fishindoAsync = ref.watch(fishindoIdProvider(widget.id));
      //_logger.d(quailtyAsync);
      fishindoAsync.whenData((fishindo) {
        setState(() {
          lokasiController.text = fishindo.lokasi ?? "";
          nelayanController.text = fishindo.nelayan ?? "";
          timbanganController.text = fishindo.timbangan.toString();
          hargaController.text = fishindo.harga.toString();

          _selectedJenisIkan = fishindo.jenisikan.toString();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final jenisikan = ref.watch(jenisikanAllProvider);
    final updateState = ref.watch(fishindoUpdateProvider);

    void update() async {
      if (!_formKey.currentState!.validate()) return;

      if (_selectedJenisIkan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih Jenis Ikan dahulu")),
        );
        return;
      }

      await ref
          .read(fishindoUpdateProvider.notifier)
          .update(
            widget.id,
            lokasiController.text,
            nelayanController.text,
            double.parse(timbanganController.text),
            double.parse(hargaController.text),
            int.parse(_selectedJenisIkan ?? "0"),
          );
    }

    /// Listen Update Result
    ref.listen(fishindoUpdateProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Success"),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 50, color: Colors.green),
                    SizedBox(height: 16),
                    Text("Fishindo berhasil diupdate"),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, "/fishindo");
                    },
                    child: const Text("Back to list"),
                  ),
                ],
              ),
        );
      }
    });

    return jenisikan.when(
      data: (workorderList) {
        final fishindoAsync = ref.watch(fishindoIdProvider(widget.id));

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.purple,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: AppColors.white,
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Fishindo Edit",
              style: TextStyle(color: AppColors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                color: AppColors.white,
                onPressed: update,
              ),
            ],
          ),
          body: fishindoAsync.when(
            data:
                (fishindo) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (updateState.isLoading)
                            const Center(child: CircularProgressIndicator()),

                          /// JENIS PEKERJAAN
                          _buildTextField(
                            controller: lokasiController,
                            label: "Lokasi",
                          ),
                          const Divider(),

                          /// WORKORDER
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Jenis Ikan",
                              labelStyle: TextStyle(fontSize: 12),
                              border: InputBorder.none,
                            ),
                            value: _selectedJenisIkan,
                            items:
                                workorderList.map((w) {
                                  return DropdownMenuItem(
                                    value: "${w.id}",
                                    child: Text(w.name),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedJenisIkan = val);
                            },
                          ),
                          const Divider(),

                          /// QTY
                          _buildTextField(
                            controller: nelayanController,
                            label: "Nelayan",
                          ),
                          const Divider(),

                          /// KETERANGAN
                          _buildTextField(
                            controller: timbanganController,
                            label: "Timbangan (Kg)",
                            keyboardType: TextInputType.number,
                          ),
                          const Divider(),

                          /// KETERANGAN
                          _buildTextField(
                            controller: hargaController,
                            label: "Harga (Rp)",
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error: $err")),
          ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (err, _) =>
              Scaffold(body: Center(child: Text("Error load WO: $err"))),
    );
  }

  // Future<void> _pickImages() async {
  //   final pickedFiles = await ImagePicker().pickMultiImage();
  //   if (pickedFiles.isNotEmpty) {
  //     setState(() {
  //       _editableImages.addAll(
  //         pickedFiles.map((f) => EditableImage(file: File(f.path))),
  //       );
  //     });
  //   }
  // }

  // Future<void> _pickImageFromCamera() async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _editableImages.add(
  //         EditableImage(file: File(pickedFile.path)),
  //       );
  //     });
  //   }
  // }

  // Future<void> _pickImages() async {
  //   final pickedFiles = await ImagePicker().pickMultiImage();
  //   if (pickedFiles.isNotEmpty) {
  //     setState(() {
  //       _images.addAll(pickedFiles.map((e) => File(e.path)));
  //     });
  //   }
  // }

  // Future<void> _pickImageFromCamera() async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _images.add(File(pickedFile.path));
  //     });
  //   }
  // }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 12, color: AppColors.dark),
    border: InputBorder.none,
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLines,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: _inputDecoration(label),
      style: const TextStyle(fontSize: 12),
      validator:
          validator ??
          (val) => val == null || val.isEmpty ? 'Field wajib diisi' : null,
    );
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

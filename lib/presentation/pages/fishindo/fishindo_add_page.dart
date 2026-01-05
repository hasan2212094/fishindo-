import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/data/models/jenisikan_model.dart';
import 'package:fishindo_app/presentation/providers/fishindo_provider.dart';

class FishindoAddPage extends ConsumerStatefulWidget {
  const FishindoAddPage({super.key});

  @override
  ConsumerState<FishindoAddPage> createState() => _FishindoAddPageState();
}

class _FishindoAddPageState extends ConsumerState<FishindoAddPage> {
  final _formKey = GlobalKey<FormState>();

  final lokasiController = TextEditingController();
  final nelayanController = TextEditingController();
  final timbanganController = TextEditingController();
  final hargaController = TextEditingController();

  final List<File> _imagesFish = [];
  final List<File> _imagesTimbangan = [];

  JenisIkanModel? _selectedJenisIkan;

  final _rupiahFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    lokasiController.dispose();
    nelayanController.dispose();
    timbanganController.dispose();
    hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jenisikan = ref.watch(jenisikanAllProvider);
    final createState = ref.watch(fishindoCreateProvider);

    ref.listen(fishindoCreateProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        _showSuccessDialog();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        title: const Text(
          "Fishindo Create",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon:
                createState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save, color: Colors.white),
            onPressed: createState.isLoading ? null : _submit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (createState.hasError)
                Text(
                  "Error: ${createState.error}",
                  style: const TextStyle(color: Colors.red),
                ),

              _buildTextField(controller: lokasiController, label: 'Lokasi'),

              const Divider(),

              jenisikan.when(
                data:
                    (items) => DropdownSearch<JenisIkanModel>(
                      items: items,
                      selectedItem: _selectedJenisIkan,
                      itemAsString: (item) => item.name ?? '-',
                      compareFn: (a, b) => a.id == b.id,
                      onChanged:
                          (val) => setState(() => _selectedJenisIkan = val),
                      validator:
                          (val) => val == null ? 'Pilih Jenis Ikan' : null,
                      popupProps: const PopupProps.dialog(showSearchBox: true),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: _inputDecoration(
                          "Jenis Ikan",
                        ),
                      ),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text(err.toString()),
              ),

              const Divider(),

              _buildTextField(controller: nelayanController, label: 'Nelayan'),

              const Divider(),

              /// TIMBANGAN
              TextFormField(
                controller: timbanganController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration("Timbangan (kg)"),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Timbangan wajib diisi";
                  }
                  if (double.tryParse(val) == null) {
                    return "Timbangan harus angka";
                  }
                  return null;
                },
              ),

              const Divider(),

              /// 💰 HARGA (RUPIAH)
              TextFormField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Harga"),
                onChanged: (value) {
                  final number = int.tryParse(
                    value.replaceAll(RegExp(r'[^0-9]'), ''),
                  );
                  if (number == null) return;

                  final formatted = _rupiahFormatter.format(number);
                  hargaController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Harga wajib diisi";
                  }
                  return null;
                },
              ),

              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImageButton(
                    Icons.camera_alt,
                    "Camera Ikan",
                    _pickImageFishFromCamera,
                  ),
                  const SizedBox(width: 8),
                  _buildImageButton(
                    Icons.camera_alt,
                    "Camera Timbangan",
                    _pickImageTimbanganFromCamera,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildImagePreview(
                _imagesFish,
                onRemove: (i) => setState(() => _imagesFish.removeAt(i)),
              ),

              const Divider(),

              _buildImagePreview(
                _imagesTimbangan,
                onRemove: (i) => setState(() => _imagesTimbangan.removeAt(i)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SUBMIT =================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedJenisIkan == null) {
      _showSnack("Pilih jenis ikan");
      return;
    }

    if (_imagesFish.isEmpty) {
      _showSnack("Foto ikan wajib");
      return;
    }

    if (_imagesTimbangan.isEmpty) {
      _showSnack("Foto timbangan wajib");
      return;
    }

    final harga =
        double.tryParse(
          hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    await ref
        .read(fishindoCreateProvider.notifier)
        .create(
          lokasiController.text,
          nelayanController.text,
          double.tryParse(timbanganController.text) ?? 0,
          harga,
          _selectedJenisIkan!.id,
          _imagesFish,
          _imagesTimbangan,
        );
  }

  // ================= IMAGE =================

  Future<void> _pickImageFishFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _imagesFish.add(File(picked.path)));
    }
  }

  Future<void> _pickImageTimbanganFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() => _imagesTimbangan.add(file));

    await _extractTimbanganFromImage(file);
  }

  // ================= OCR =================

  Future<void> _extractTimbanganFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final result = await textRecognizer.processImage(inputImage);
      final text = result.text.replaceAll(',', '.');

      final match = RegExp(r'\d+(\.\d+)?').firstMatch(text);

      if (match != null) {
        timbanganController.text = match.group(0)!;
      } else {
        _showSnack("Angka timbangan tidak terdeteksi");
      }
    } catch (_) {
      _showSnack("OCR gagal membaca timbangan");
    } finally {
      textRecognizer.close();
    }
  }

  // ================= UI =================

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 12),
    border: InputBorder.none,
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label),
      validator:
          (val) => val == null || val.isEmpty ? 'Field wajib diisi' : null,
    );
  }

  Widget _buildImageButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 10)),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
    );
  }

  Widget _buildImagePreview(
    List<File> images, {
    required Function(int) onRemove,
  }) {
    if (images.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          images.asMap().entries.map((e) {
            return Stack(
              children: [
                Image.file(e.value, width: 120, height: 120, fit: BoxFit.cover),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                    onPressed: () => onRemove(e.key),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
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
                  Navigator.pushReplacementNamed(context, "/fishindo");
                },
                child: const Text("Back to list"),
              ),
            ],
          ),
    );
  }
}

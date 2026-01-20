// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fishindo_app/core/constants/app_colors.dart';
// import 'package:fishindo_app/presentation/providers/ikan_provider.dart';

// class IkanAddPage extends ConsumerStatefulWidget {
//   const IkanAddPage({super.key});

//   @override
//   ConsumerState<IkanAddPage> createState() => _IkanAddPageState();
// }

// class _IkanAddPageState extends ConsumerState<IkanAddPage> {
//   final _formKey = GlobalKey<FormState>();

//   // Controller untuk field
//   final TextEditingController nameController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final addState = ref.watch(ikanCreateProvider);

//     /// Fungsi untuk tambah data workorder
//     void addIkan() async {
//       if (_formKey.currentState!.validate()) {
//         await ref.read(ikanCreateProvider.notifier).create(nameController.text);
//       }
//     }

//     /// Listener untuk hasil tambah
//     ref.listen(ikanCreateProvider, (previous, next) {
//       if (next is AsyncData && next.value != null) {
//         showDialog(
//           context: context,
//           builder:
//               (context) => AlertDialog(
//                 title: const Text("Success", textAlign: TextAlign.center),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 content: const Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(height: 16),
//                     Icon(Icons.check_circle, color: Colors.green, size: 50),
//                     SizedBox(height: 8),
//                     Text(
//                       "Workorder created successfully!",
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context, true);
//                       Navigator.pushReplacementNamed(context, "/workorder");
//                     },
//                     child: const Text("Back to list"),
//                   ),
//                 ],
//               ),
//         );
//       }
//     });

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.purple,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           color: AppColors.white,
//           iconSize: 18,
//           onPressed: () => Navigator.pop(context, true),
//         ),
//         title: const Text(
//           "Add Workorder",
//           style: TextStyle(color: AppColors.white, fontSize: 16),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add_reaction_outlined),
//             color: AppColors.white,
//             iconSize: 20,
//             onPressed: addIkan,
//           ),
//         ],
//       ),
//       backgroundColor: AppColors.light,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (addState.isLoading)
//                   Transform.scale(
//                     scale: 0.5,
//                     child: const CircularProgressIndicator(),
//                   ),
//                 if (addState.hasError)
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 4,
//                           horizontal: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.danger,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           "Error: ${addState.error}",
//                           style: const TextStyle(
//                             color: AppColors.white,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                 // Field Nomor Workorder
//                 TextFormField(
//                   controller: nameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Nama Ikan',
//                     labelStyle: TextStyle(fontSize: 12, color: AppColors.dark),
//                     border: InputBorder.none,
//                   ),
//                   style: const TextStyle(fontSize: 12),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Nama ikan tidak boleh kosong';
//                     }
//                     return null;
//                   },
//                 ),
//                 const Divider(thickness: 0.5, height: 0),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
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

  /// 0 = Pelagis, 1 = Demersal
  int _status_kelompok = 0;

  @override
  Widget build(BuildContext context) {
    final addState = ref.watch(ikanCreateProvider);

    /// Fungsi tambah ikan
    void addIkan() async {
      if (_formKey.currentState!.validate()) {
        await ref
            .read(ikanCreateProvider.notifier)
            .create(
              nameController.text,
              _status_kelompok, // INT aman
            );
      }
    }

    /// Listener hasil submit
    ref.listen(ikanCreateProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
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
                  children: [
                    SizedBox(height: 16),
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                    SizedBox(height: 8),
                    Text(
                      "Data ikan berhasil ditambahkan",
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
                    child: const Text("Kembali"),
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
          "Add Ikan",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            color: AppColors.white,
            iconSize: 20,
            onPressed: addIkan,
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
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
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

                /// Nama Ikan
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

                const SizedBox(height: 12),

                /// STATUS KATEGORI (AMAN - INT)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Kategori Ikan",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _status_kelompok == 0 ? "Pelagis" : "Demersal",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  _status_kelompok == 0
                                      ? Colors.blue
                                      : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _status_kelompok == 1,
                        onChanged: (value) {
                          setState(() {
                            _status_kelompok = value ? 1 : 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

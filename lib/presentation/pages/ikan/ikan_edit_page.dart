// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fishindo_app/core/constants/app_colors.dart';
// import 'package:fishindo_app/presentation/providers/ikan_provider.dart';

// class IkanEditPage extends ConsumerStatefulWidget {
//   final int id;
//   const IkanEditPage({super.key, required this.id});

//   @override
//   ConsumerState<IkanEditPage> createState() => _IkanEditPageState();
// }

// class _IkanEditPageState extends ConsumerState<IkanEditPage> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController nameController = TextEditingController();

//   bool isSuccess = false;

//   @override
//   void initState() {
//     super.initState();

//     // invalidate data lama agar fetch ulang
//     Future.microtask(() {
//       ref.invalidate(ikanByIdProvider(widget.id));
//     });
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ikanAsync = ref.watch(ikanByIdProvider(widget.id));
//     final editState = ref.watch(ikanEditProvider);

//     // Fungsi update
//     void update() async {
//       if (!mounted) return;

//       if (_formKey.currentState!.validate()) {
//         setState(() {
//           isSuccess = false;
//         });

//         try {
//           await ref
//               .read(ikanEditProvider.notifier)
//               .update(widget.id, nameController.text);
//         } catch (e) {
//           if (context.mounted) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text("Error: $e")));
//           }
//           return;
//         }
//       }
//     }

//     // Listener untuk sukses update
//     ref.listen(ikanEditProvider, (previous, next) {
//       if (next is AsyncData && next.value != null) {
//         setState(() {
//           isSuccess = true;
//         });

//         if (!context.mounted) return;

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
//                       "Workorder updated successfully!",
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
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
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Edit Workorder",
//           style: TextStyle(color: AppColors.white, fontSize: 16),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             color: AppColors.white,
//             iconSize: 18,
//             onPressed: update,
//           ),
//         ],
//       ),
//       backgroundColor: AppColors.light,
//       body: ikanAsync.when(
//         data: (ikan) {
//           if (nameController.text.isEmpty) {
//             nameController.text = ikan.name ?? '';
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 keyboardDismissBehavior:
//                     ScrollViewKeyboardDismissBehavior.onDrag,
//                 child: Column(
//                   children: [
//                     if (editState.isLoading)
//                       Transform.scale(
//                         scale: 0.5,
//                         child: const CircularProgressIndicator(),
//                       ),
//                     if (editState.hasError)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 4,
//                               horizontal: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColors.danger,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               "Error: ${editState.error}",
//                               style: const TextStyle(
//                                 color: AppColors.white,
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     // Field Nomor Workorder
//                     TextFormField(
//                       controller: nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Nama Ikan',
//                         labelStyle: TextStyle(
//                           fontSize: 12,
//                           color: AppColors.dark,
//                         ),
//                         border: InputBorder.none,
//                       ),
//                       style: const TextStyle(fontSize: 12),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Nama ikan tidak boleh kosong';
//                         }
//                         return null;
//                       },
//                     ),
//                     const Divider(thickness: 0.5, height: 0),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, _) => Center(child: Text("Error: $err")),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/providers/ikan_provider.dart';

class IkanEditPage extends ConsumerStatefulWidget {
  final int id;
  const IkanEditPage({super.key, required this.id});

  @override
  ConsumerState<IkanEditPage> createState() => _IkanEditPageState();
}

class _IkanEditPageState extends ConsumerState<IkanEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  /// 🔒 TAMBAHAN AMAN
  /// 0 = Pelagis, 1 = Demersal
  int _status_kelompok = 0;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(ikanByIdProvider(widget.id));
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ikanAsync = ref.watch(ikanByIdProvider(widget.id));
    final editState = ref.watch(ikanEditProvider);

    /// Fungsi update (AMAN)
    void update() async {
      if (!_formKey.currentState!.validate()) return;

      try {
        await ref
            .read(ikanEditProvider.notifier)
            .update(
              widget.id,
              nameController.text,
              _status_kelompok, // 🔒 INT tambahan
            );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }

    /// Listener sukses
    ref.listen(ikanEditProvider, (previous, next) {
      if (next is AsyncData && next.value != null && context.mounted) {
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
                  children: [
                    SizedBox(height: 16),
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                    SizedBox(height: 8),
                    Text(
                      "Ikan updated successfully!",
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
          "Edit Ikan",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            color: AppColors.white,
            onPressed: update,
          ),
        ],
      ),
      backgroundColor: AppColors.light,
      body: ikanAsync.when(
        data: (ikan) {
          /// 🔒 INIT SEKALI (AMAN)
          if (!_isInit) {
            nameController.text = ikan.name ?? '';
            _status_kelompok = ikan.status_kelompok ?? 0;
            _isInit = true;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (editState.isLoading)
                      Transform.scale(
                        scale: 0.5,
                        child: const CircularProgressIndicator(),
                      ),

                    if (editState.hasError)
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
                          "Error: ${editState.error}",
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
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.dark,
                        ),
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
                    const Divider(thickness: 0.5),

                    const SizedBox(height: 12),

                    /// 🔒 STATUS KATEGORI (INT - AMAN)
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
                                "Kelompok Ikan",
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

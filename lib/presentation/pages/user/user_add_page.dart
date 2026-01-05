import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

import '../../providers/user_provider.dart';

class UserAddPage extends ConsumerStatefulWidget {
  const UserAddPage({super.key});

  @override
  ConsumerState<UserAddPage> createState() => _UserAddPageState();
}

class _UserAddPageState extends ConsumerState<UserAddPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? selectedRole;

  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(roleProvider);
    final registerState = ref.watch(registerProvider);

    void register() async {
      if (_formKey.currentState!.validate()) {
        if (selectedRole == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pilih role terlebih dahulu")),
          );
          return;
        }
        setState(() {
          isSuccess = false;
        });

        await ref
            .read(registerProvider.notifier)
            .register(
              nameController.text,
              emailController.text,
              passwordController.text,
              int.parse(selectedRole!),
            );
      }
    }

    ref.listen(registerProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        setState(() {
          isSuccess = true;
        });

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
                      "User created successfully!",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      //Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, "/user");
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
          "User Add",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_reaction_outlined),
            color: AppColors.white,
            iconSize: 20,
            onPressed: register,
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
                if (registerState.isLoading)
                  Transform.scale(
                    scale: 0.5,
                    child: const CircularProgressIndicator(),
                  ),
                if (registerState.hasError)
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
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Error: ${registerState.error}",
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
                    labelText: 'Name',
                    labelStyle: TextStyle(fontSize: 12, color: AppColors.dark),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 12),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const Divider(thickness: 0.5, height: 0),

                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 12, color: AppColors.dark),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 12),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                const Divider(thickness: 0.5, height: 0),

                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: 12, color: AppColors.dark),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 12),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const Divider(thickness: 0.5, height: 0),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    labelStyle: TextStyle(fontSize: 12),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 12, color: AppColors.dark),
                  value: selectedRole,
                  items: roles.when(
                    data:
                        (roleList) =>
                            roleList.map((role) {
                              return DropdownMenuItem<String>(
                                value: role.id.toString(),
                                child: Text(role.name),
                              );
                            }).toList(),
                    loading:
                        () => [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("Loading role list..."),
                          ),
                        ],
                    error:
                        (err, _) => [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("Error loading roles"),
                          ),
                        ],
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                ),

                const Divider(thickness: 0.5, height: 0),
                // registerState.when(
                //   data: (data) => Column(
                //     children: [
                //       ElevatedButton(
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.blue,
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(8),
                //           ),
                //           minimumSize: const Size(double.infinity, 50),
                //         ),
                //         onPressed: register,
                //         child: registerState.isLoading
                //             ? const CircularProgressIndicator()
                //             : const Text('Register',
                //                 style: TextStyle(
                //                     color: Colors.white, fontSize: 16)),
                //       ),
                //       if (data == null && registerState.hasError) ...[
                //         const SizedBox(height: 8),
                //         Text(
                //           registerState.error?.toString() ?? '',
                //           style: const TextStyle(color: Colors.red),
                //         ),
                //       ],
                //     ],
                //   ),
                //   loading: () => const Center(
                //     child: CircularProgressIndicator(),
                //   ),
                //   error: (error, _) => Column(
                //     children: [
                //       ElevatedButton(
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.blue,
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(30),
                //           ),
                //           minimumSize: const Size(double.infinity, 50),
                //         ),
                //         onPressed: register,
                //         child: const Text('Register',
                //             style:
                //                 TextStyle(color: Colors.white, fontSize: 16)),
                //       ),
                //       const SizedBox(height: 8),
                //       Text(
                //         'error: $error',
                //         style: const TextStyle(color: Colors.red),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

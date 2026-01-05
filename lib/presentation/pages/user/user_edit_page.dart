import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/providers/user_provider.dart';

class UserEditPage extends ConsumerStatefulWidget {
  final int userId;
  const UserEditPage({super.key, required this.userId});

  @override
  ConsumerState<UserEditPage> createState() => _UserEditPagetate();
}

class _UserEditPagetate extends ConsumerState<UserEditPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? selectedRole;

  bool isSuccess = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.invalidate(userIdProvider(widget.userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(roleProvider);
    final userAsync = ref.watch(userIdProvider(widget.userId));

    final editState = ref.watch(userEditProvider);

    void update() async {
      if (!mounted) return;

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

        try {
          await ref
              .read(userEditProvider.notifier)
              .update(
                idController.text,
                nameController.text,
                emailController.text,
                passwordController.text,
                int.parse(selectedRole!),
              );
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

    ref.listen(userEditProvider, (previous, next) {
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
                      "User edited successfully!",
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
          "User Edit",
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
      body: userAsync.when(
        data: (user) {
          if (idController.text.isEmpty) {
            idController.text = user.id.toString();
            nameController.text = user.name;
            emailController.text = user.email;
          }

          if (selectedRole == null) {
            setState(() {
              selectedRole = user.roleid.toString();
            });
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
                              shape: BoxShape.rectangle,
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
                    TextFormField(
                      controller: idController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Id',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.dark,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Divider(thickness: 0.5, height: 0),
                    TextFormField(
                      controller: emailController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.dark,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Divider(thickness: 0.5, height: 0),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.dark,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Divider(thickness: 0.5, height: 0),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.dark,
                        ),
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.dark,
                      ),
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

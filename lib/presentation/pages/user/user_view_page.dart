import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/providers/user_provider.dart';
import 'user_edit_page.dart';

class UserViewPage extends ConsumerStatefulWidget {
  final int userId;
  const UserViewPage({super.key, required this.userId});

  @override
  ConsumerState<UserViewPage> createState() => _UserViewPageState();
}

class _UserViewPageState extends ConsumerState<UserViewPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? selectedRole;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(
      userIdProvider(widget.userId),
    ); // Paksa refresh setiap halaman dibuka
  }

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(roleProvider);
    final userAsync = ref.watch(userIdProvider(widget.userId));
    final deleteState = ref.watch(userDeleteProvider);

    void delete() async {
      try {
        await ref
            .read(userDeleteProvider.notifier)
            .delete(widget.userId.toString());
      } catch (e) {
        debugPrint("Error deleting assignment: $e");
      }
    }

    ref.listen(userDeleteProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        ref.invalidate(userDeleteProvider);
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
                      "User removed successfully!",
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
          "User View",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: AppColors.danger,
            iconSize: 18,
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Confirm Delete"),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      content: const Text(
                        "Are you sure you want to remove this user?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: delete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                          ),
                          child: const Text(
                            "Yes, Remove !",
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            color: AppColors.white,
            iconSize: 18,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserEditPage(userId: widget.userId),
                ),
              );
            },
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

          selectedRole ??= user.roleid.toString();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (deleteState.isLoading)
                    Transform.scale(
                      scale: 0.5,
                      child: const CircularProgressIndicator(),
                    ),
                  if (deleteState.hasError)
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
                            "Error: ${deleteState.error}",
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
                    readOnly: true,
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
                  IgnorePointer(
                    ignoring: true,
                    child: DropdownButtonFormField<String>(
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
                  ),
                  const Divider(thickness: 0.5, height: 0),
                ],
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

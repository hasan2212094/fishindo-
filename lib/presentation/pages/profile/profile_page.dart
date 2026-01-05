import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../home/home_menu.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  //return "${info.version}+${info.buildNumber}";
  return info.version;
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.purple,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final userProfile = ref.watch(userProfileProvider);
    final appVersion = ref.watch(appVersionProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.white,
          iconSize: 18,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeMenuPage(initialIndex: 0),
              ),
              (route) => false,
            );
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
      ),
      body: userProfile.when(
        data: (user) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: TextEditingController(text: user.name),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, size: 16),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Divider(thickness: 0.5, height: 0),
                  TextFormField(
                    controller: TextEditingController(text: user.email),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, size: 16),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Divider(thickness: 0.5, height: 0),
                  TextFormField(
                    controller: TextEditingController(text: user.rolename),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.account_box, size: 16),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Divider(thickness: 0.5, height: 0),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final authNotifier = ref.read(authProvider.notifier);
                        await authNotifier.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: AppColors.white, size: 12),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  appVersion.when(
                    data:
                        (version) => Text(
                          'Version $version',
                          style: const TextStyle(fontSize: 10),
                        ),
                    loading:
                        () => const Text(
                          'Memuat versi...',
                          style: TextStyle(fontSize: 10),
                        ),
                    error:
                        (err, stack) => const Text(
                          'Versi tidak tersedia',
                          style: TextStyle(fontSize: 10),
                        ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Error: $error")),
      ),
    );
  }
}

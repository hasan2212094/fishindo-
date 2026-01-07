import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home/home_menu.dart';
import 'presentation/providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Belum login → langsung LoginPage
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LoginPage(),
          );
        }

        // Sudah login → langsung HomeMenu
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomeMenuPage(), // sesuaikan nama class kamu
        );
      },
      loading:
          () => const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
      error:
          (e, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: Text('Auth error'))),
          ),
    );
  }
}

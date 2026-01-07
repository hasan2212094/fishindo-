import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/pages/auth/login_page.dart';
import 'package:fishindo_app/presentation/pages/home/home_menu.dart';
import 'routes.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return auth.when(
      data: (user) {
        // BELUM LOGIN → tampilkan LoginPage
        if (user == null) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LoginPage(),
          );
        }

        // SUDAH LOGIN → langsung HomeMenu
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          routes: {
            '/login': (context) => const LoginPage(),
            '/homemenu': (context) => const HomeMenuPage(),
            // kalau ada route lain, tambahkan di sini
          },
          home: const HomeMenuPage(),
        );
      },
      loading:
          () => const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
      error:
          (e, _) => MaterialApp(
            home: Scaffold(body: Center(child: Text('Auth error'))),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home/home_menu.dart';
import 'presentation/pages/ikan/ikan_add_page.dart';
import 'presentation/providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomeMenuPage(), // homepage route
        '/ikanadd': (context) => const IkanAddPage(),
      },
      builder: (context, child) {
        return authState.when(
          data: (user) {
            if (user == null) {
              // Belum login → tampilkan LoginPage
              return const LoginPage();
            } else {
              // Sudah login → tampilkan child dari MaterialApp
              return child ?? const HomeMenuPage();
            }
          },
          loading:
              () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
          error:
              (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
        );
      },
    );
  }
}

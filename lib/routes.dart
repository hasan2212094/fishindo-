import 'package:flutter/material.dart';
import 'package:fishindo_app/presentation/pages/home/home_menu.dart';
import 'package:fishindo_app/presentation/pages/home/home_page.dart';
import 'package:fishindo_app/presentation/pages/profile/profile_page.dart';
import 'package:fishindo_app/presentation/pages/splashscreen/splashscreen_page.dart';
import 'package:fishindo_app/presentation/pages/user/user_add_page.dart';
import 'package:fishindo_app/presentation/pages/user/user_list_page.dart';
import 'package:fishindo_app/presentation/pages/fishindo/fishindo_list_page.dart';
import 'package:fishindo_app/presentation/pages/fishindo/fishindo_add_page.dart';
import 'package:fishindo_app/presentation/pages/jenisikan/jenisikan_add_page.dart';
import 'package:fishindo_app/presentation/pages/jenisikan/jenisikan_list_page.dart';
import 'presentation/pages/auth/login_page.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreenPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/homemenu':
        return MaterialPageRoute(builder: (_) => const HomeMenuPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/user':
        return MaterialPageRoute(builder: (_) => const UserListPage());

      case '/useradd':
        return MaterialPageRoute(builder: (_) => const UserAddPage());
      case '/fishindo':
        return MaterialPageRoute(builder: (_) => const FishindoListPage());
      case '/fishindoadd':
        return MaterialPageRoute(builder: (_) => const FishindoAddPage());
      case '/jenisikan':
        return MaterialPageRoute(builder: (_) => const JenisikanListPage());
      case '/jenisikanadd':
        return MaterialPageRoute(builder: (_) => const JenisikanAddPage());

      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}

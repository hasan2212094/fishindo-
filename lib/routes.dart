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
import 'package:fishindo_app/presentation/pages/ikan/ikan_add_page.dart';
import 'package:fishindo_app/presentation/pages/ikan/ikan_list_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/widgets/connection_snackbar.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: SplashScreenPage()),
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: LoginPage()),
        );

      case '/homemenu':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: HomeMenuPage()),
        );

      case '/home':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: HomePage()),
        );

      case '/user':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: UserListPage()),
        );

      case '/useradd':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: UserAddPage()),
        );

      case '/fishindo':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: FishindoListPage()),
        );

      case '/fishindoadd':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: FishindoAddPage()),
        );

      case '/jenisikan':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: JenisikanListPage()),
        );

      case '/jenisikanadd':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: JenisikanAddPage()),
        );
      case '/ikan':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: IkanListPage()),
        );

      case '/ikanadd':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: IkanAddPage()),
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const ConnectionSnackbar(child: ProfilePage()),
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => const ConnectionSnackbar(
                child: Scaffold(
                  body: Center(child: Text('No route defined for this page')),
                ),
              ),
        );
    }
  }
}

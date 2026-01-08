import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import 'package:fishindo_app/presentation/pages/home/home_page.dart';
import 'package:fishindo_app/presentation/pages/profile/profile_page.dart';
import 'package:fishindo_app/presentation/pages/user/user_list_page.dart';
import 'package:fishindo_app/presentation/pages/fishindo/fishindo_list_page.dart';
import 'package:fishindo_app/presentation/pages/jenisikan/jenisikan_list_page.dart';
import 'package:fishindo_app/presentation/pages/mainbox/mainbox_list_page.dart'; // ✅ Import MainBoxListPage

import '../../../core/services/storage_service.dart';

class HomeMenuPage extends ConsumerStatefulWidget {
  final int initialIndex;
  final int assignmentShowFilter;

  const HomeMenuPage({
    super.key,
    this.initialIndex = 0,
    this.assignmentShowFilter = 0,
  });

  @override
  ConsumerState<HomeMenuPage> createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends ConsumerState<HomeMenuPage> {
  late int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<String?> getUserRole() async {
    return await StorageService.getRoleName();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (_currentIndex == 0) {
            SystemNavigator.pop();
          } else {
            setState(() {
              _currentIndex = 0;
            });
          }
        }
      },
      child: FutureBuilder<String?>(
        future: getUserRole(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          String? role = snapshot.data;
          final List<Map<String, dynamic>> menu = [
            {
              'page': const HomePage(),
              'item': BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: _currentIndex == 0 ? AppColors.purple : Colors.grey,
                ),
                label: 'Home',
              ),
            },
            {
              'page': const JenisikanListPage(),
              'item': BottomNavigationBarItem(
                icon: Icon(
                  Icons.set_meal_rounded,
                  color: _currentIndex == 1 ? AppColors.purple : Colors.grey,
                ),
                label: 'Jenis Ikan',
              ),
            },
          ];

          // ===== Tambahkan menu IKAN =====
          menu.add({
            'page': MainBoxListPage(), // ✅ MainBoxListPage
            'item': BottomNavigationBarItem(
              icon: Icon(
                Icons.water,
                color: _currentIndex == 2 ? AppColors.purple : Colors.grey,
              ),
              label: 'IKAN',
            ),
          });

          // Laporan
          menu.add({
            'page': const FishindoListPage(),
            'item': BottomNavigationBarItem(
              icon: Icon(
                Icons.bar_chart,
                color: _currentIndex == 3 ? AppColors.purple : Colors.grey,
              ),
              label: 'Laporan',
            ),
          });

          // Menu khusus Admin
          if (role == "Admin") {
            menu.addAll([
              {
                'page': const UserListPage(),
                'item': BottomNavigationBarItem(
                  icon: Icon(
                    Icons.manage_accounts_rounded,
                    color:
                        _currentIndex == menu.length
                            ? AppColors.purple
                            : Colors.grey,
                  ),
                  label: 'Manage User',
                ),
              },
            ]);
          }

          // Profile terakhir
          menu.add({
            'page': const ProfilePage(),
            'item': BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color:
                    _currentIndex == menu.length
                        ? AppColors.purple
                        : Colors.grey,
              ),
              label: 'Profile',
            ),
          });

          // Pastikan index aman
          if (_currentIndex >= menu.length) {
            _currentIndex = 0;
          }

          return Scaffold(
            body: SafeArea(child: menu[_currentIndex]['page']),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              selectedItemColor: AppColors.purple,
              unselectedItemColor: Colors.grey,
              items:
                  menu
                      .map((e) => e['item'] as BottomNavigationBarItem)
                      .toList(),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreenPage extends ConsumerStatefulWidget {
  const SplashScreenPage({super.key});

  @override
  SplashScreenPageState createState() => SplashScreenPageState();
}

bool permissionGranted = false;

class SplashScreenPageState extends ConsumerState<SplashScreenPage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _checkPermission();
    _startAnimation();
    _checkToken();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.notification.status;

    if (!status.isGranted) {
      if (mounted) {
        await _showPermissionDialog();
      }
    }
  }

  Future<void> _showPermissionDialog() async {
    await showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text("Notification Permission"),
            content: const Text(
              "This app requires permission to send notifications. Please enable it in settings.",
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                child: const Text("Open Settings"),
                onPressed: () async {
                  Navigator.pop(context, true);
                  await openAppSettings();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _opacity = 1.0;
    });
  }

  Future<void> _checkToken() async {
    final token = await StorageService.getToken();
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (token != null) {
        Navigator.pushReplacementNamed(context, "/homemenu");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/icon/icon_sis.png'),
              ),
              SizedBox(height: 16),
              Text(
                'FISHINDO TASK APP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.light,
                ),
              ),
            ],
          ),
          // child: const Text(
          //   "SIS Task App",
          //   style: TextStyle(fontSize: 24, color: Colors.white),
          // ),
        ),
      ),
    );
  }
}

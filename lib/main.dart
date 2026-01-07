import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fishindo_app/core/services/snackbar_service.dart';
import 'package:fishindo_app/presentation/pages/home/home_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _subscription;
  ConnectivityResult? _lastStatus;

  @override
  void initState() {
    super.initState();

    _subscription = Connectivity().onConnectivityChanged.listen((status) {
      if (_lastStatus == status) return;
      _lastStatus = status;

      scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              status == ConnectivityResult.none
                  ? 'Connection lost'
                  : 'Connection restored',
            ),
            backgroundColor:
                status == ConnectivityResult.none ? Colors.red : Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey, // ⭐ INI KUNCI UTAMA
      debugShowCheckedModeBanner: false,
      home: const HomePage(), // app kamu
    );
  }
}

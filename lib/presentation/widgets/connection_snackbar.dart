import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/services/snackbar_service.dart';

class ConnectionSnackbar extends StatefulWidget {
  final Widget child;
  const ConnectionSnackbar({super.key, required this.child});

  @override
  State<ConnectionSnackbar> createState() => _ConnectionSnackbarState();
}

class _ConnectionSnackbarState extends State<ConnectionSnackbar> {
  late StreamSubscription<ConnectivityResult> _subscription;
  ConnectivityResult? _lastStatus;

  @override
  void initState() {
    super.initState();

    _subscription = Connectivity().onConnectivityChanged.listen((status) {
      if (_lastStatus == status) return; // hindari duplicate
      _lastStatus = status;

      showGlobalSnackBar(
        status == ConnectivityResult.none
            ? 'Connection lost'
            : 'Connection restored',
        background:
            status == ConnectivityResult.none ? Colors.red : Colors.green,
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
    return widget.child;
  }
}

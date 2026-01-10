import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'dart:async';

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;
  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();

    // 🔹 Setup koneksi
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;

    // cek koneksi awal
    _connectivity.checkConnectivity().then((result) {
      setState(() => _connectionStatus = result);
    });

    // listen perubahan koneksi
    _connectivitySubscription = _connectivityStream.listen((result) {
      setState(() => _connectionStatus = result);
    });

    // 🔹 Load saved email/password
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedCredentials();
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ===== Load email & password tersimpan =====
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email') ?? '';
    final savedPassword = prefs.getString('password') ?? '';

    _emailController.text = savedEmail;
    _passwordController.text = savedPassword;
  }

  /// ===== Simpan email & password =====
  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .login(_emailController.text, _passwordController.text);

    // Simpan credentials
    await _saveCredentials(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final appVersion = ref.watch(appVersionProvider);

    ref.listen(authProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        Navigator.pushReplacementNamed(context, '/homemenu');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/image/login_image2.svg',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to',
                  style: TextStyle(fontSize: 20, color: AppColors.dark),
                ),
                const Text(
                  'FISHINDO TASK APPLICATION',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 10),
                appVersion.when(
                  data:
                      (v) => Text(
                        'Version $v',
                        style: const TextStyle(color: AppColors.purple),
                      ),
                  loading:
                      () => const Text(
                        'Memuat versi...',
                        style: TextStyle(fontSize: 10),
                      ),
                  error:
                      (e, _) => const Text(
                        'Versi tidak tersedia',
                        style: TextStyle(fontSize: 10),
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Email wajib diisi';
                    final regex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
                    );
                    if (!regex.hasMatch(value))
                      return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator:
                      (value) => value!.isEmpty ? 'Password wajib diisi' : null,
                ),
                const SizedBox(height: 12),

                /// 🔹 Status koneksi
                Text(
                  _connectionStatus == ConnectivityResult.none
                      ? 'Tidak ada koneksi internet'
                      : 'Internet tersambung',
                  style: TextStyle(
                    color:
                        _connectionStatus == ConnectivityResult.none
                            ? Colors.red
                            : Colors.green,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                authState.when(
                  data:
                      (data) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _login,
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  loading: () => const CircularProgressIndicator(),
                  error:
                      (e, _) => Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: _login,
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            e.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

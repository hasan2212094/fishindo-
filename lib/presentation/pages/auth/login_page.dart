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

  bool _rememberMe = false;
  bool _isValid = false;
  bool _credentialsLoaded = false;

  late final Connectivity _connectivity;
  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();

    // 🔹 Setup koneksi
    _connectivity = Connectivity();
    _connectivity.checkConnectivity().then((result) {
      if (mounted) setState(() => _connectionStatus = result);
    });
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      result,
    ) {
      if (mounted) setState(() => _connectionStatus = result);
    });

    // 🔹 Listener validasi
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);

    // 🔹 Load saved credentials hanya sekali
    _loadSavedCredentials();
  }

  void _validateForm() {
    final valid =
        _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    if (_isValid != valid && mounted) setState(() => _isValid = valid);
  }

  Future<void> _loadSavedCredentials() async {
    if (_credentialsLoaded) return;
    _credentialsLoaded = true;

    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;

    if (remember) {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    }

    if (mounted) setState(() => _rememberMe = remember);
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await ref.read(authProvider.notifier).login(email, password);

      // 🔹 Save credentials hanya saat login berhasil
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _rememberMe);
      if (_rememberMe) {
        await prefs.setString('email', email);
        await prefs.setString('password', password);
      } else {
        await prefs.remove('email');
        await prefs.remove('password');
      }

      if (mounted) Navigator.pushReplacementNamed(context, '/homemenu');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login gagal: $e")));
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final appVersion = ref.watch(appVersionProvider);

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
                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged:
                          (val) => setState(() => _rememberMe = val ?? false),
                    ),
                    const Text("Remember me"),
                  ],
                ),
                const SizedBox(height: 16),

                authState.when(
                  data:
                      (_) => ElevatedButton(
                        onPressed: _isValid ? _login : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isValid ? AppColors.purple : Colors.grey,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  loading:
                      () => const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                  error:
                      (e, _) => Column(
                        children: [
                          ElevatedButton(
                            onPressed: _isValid ? _login : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isValid ? AppColors.purple : Colors.grey,
                              minimumSize: const Size(double.infinity, 50),
                            ),
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

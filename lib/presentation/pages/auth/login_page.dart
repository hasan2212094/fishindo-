import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  //return "${info.version}+${info.buildNumber}";
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    void login() async {
      if (_formKey.currentState!.validate()) {
        await ref.read(authProvider.notifier).login(
              _emailController.text,
              _passwordController.text,
            );
      }
    }

    ref.listen(authProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        Navigator.pushReplacementNamed(context, '/homemenu');
      }
    });

    final appVersion = ref.watch(appVersionProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      child: SvgPicture.asset(
                        'assets/image/login_image2.svg',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Welcome to',
                        style: TextStyle(
                          fontSize: 20,
                          //fontWeight: FontWeight.normal,
                          color: AppColors.dark,
                        )),
                    const Text('FISHINDO TASK APPLICATION',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark)),
                    const SizedBox(height: 10),
                    appVersion.when(
                      data: (version) => Text(
                        'Version $version',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.purple),
                      ),
                      loading: () => const Text('Memuat versi...',
                          style: TextStyle(fontSize: 10)),
                      error: (err, stack) => const Text('Versi tidak tersedia',
                          style: TextStyle(fontSize: 10)),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.person),
                        // border: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email wajib diisi';
                        }
                        final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        // border: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(8)),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    authState.when(
                      data: (data) => Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: login,
                            child: const Text('Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ),
                          if (data == null && authState.hasError) ...[
                            const SizedBox(height: 8),
                            Text(
                              authState.error?.toString() ?? '',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: login,
                            child: const Text('Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
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
        ),
      ),
    );
  }
}

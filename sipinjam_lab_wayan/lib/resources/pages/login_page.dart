import '/config/app.dart';
import '/app/controllers/login_controller.dart';
import '/app/helpers/auth_redirect.dart';
import '/resources/widgets/logo_widget.dart';
import '/resources/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LoginPage extends NyStatefulWidget<LoginController> {
  static RouteView path = ("/login", (_) => LoginPage());

  LoginPage({super.key}) : super(child: () => _LoginPageState());
}

class _LoginPageState extends NyPage<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  get init => () async {
    if (await Auth.isAuthenticated()) {
      routeToHomeForRole();
    }
  };

  @override
  LoadingStyle get loadingStyle => LoadingStyle.normal();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await widget.controller.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      showToastDanger(description: "Email atau kata sandi salah");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: Logo()),
                  Spacing.vertical(16),
                  Text(
                    AppConfig.appName,
                    textAlign: TextAlign.center,
                  ).displaySmall(),
                  Spacing.vertical(4),
                  const Text(
                    "Sistem Peminjaman Alat Laboratorium",
                    textAlign: TextAlign.center,
                  ).bodyMedium(),
                  Spacing.vertical(32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email wajib diisi";
                      }
                      return null;
                    },
                  ),
                  Spacing.vertical(16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password wajib diisi";
                      }
                      return null;
                    },
                  ),
                  Spacing.vertical(24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Masuk"),
                  ),
                  Spacing.vertical(12),
                  TextButton(
                    onPressed: () => routeTo(RegisterPage.path),
                    child: const Text("Belum punya akun? Daftar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

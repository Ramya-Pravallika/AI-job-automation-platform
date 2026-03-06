import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_indicator.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final provider = context.read<AuthProvider>();
    final ok = await provider.login(_emailController.text.trim(), _passwordController.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, DashboardScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            if (auth.isLoading) const LoadingIndicator(),
            if (auth.error != null) ErrorMessage(message: auth.error!),
            ElevatedButton(onPressed: auth.isLoading ? null : _login, child: const Text('Login')),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, SignupScreen.route),
              child: const Text('Create account'),
            )
          ],
        ),
      ),
    );
  }
}

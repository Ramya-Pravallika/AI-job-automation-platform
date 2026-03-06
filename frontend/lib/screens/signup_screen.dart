import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_indicator.dart';
import 'dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const route = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final provider = context.read<AuthProvider>();
    final ok = await provider.signup(_emailController.text.trim(), _passwordController.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, DashboardScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
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
            ElevatedButton(onPressed: auth.isLoading ? null : _signup, child: const Text('Signup')),
          ],
        ),
      ),
    );
  }
}

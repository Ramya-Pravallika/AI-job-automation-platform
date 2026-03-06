import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/job.dart';
import 'providers/application_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'screens/applications_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/job_detail_screen.dart';
import 'screens/job_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/resume_upload_screen.dart';
import 'screens/signup_screen.dart';
import 'services/api_service.dart';
import 'services/application_service.dart';
import 'services/auth_service.dart';
import 'services/job_service.dart';

void main() {
  final apiService = ApiService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService(apiService))),
        ChangeNotifierProvider(create: (_) => JobProvider(JobService(apiService))),
        ChangeNotifierProvider(create: (_) => ApplicationProvider(ApplicationService(apiService))),
        Provider(create: (_) => apiService),
      ],
      child: const JobAutomationApp(),
    ),
  );
}

class JobAutomationApp extends StatelessWidget {
  const JobAutomationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Job Automation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const AppGate(),
      routes: {
        LoginScreen.route: (_) => const LoginScreen(),
        SignupScreen.route: (_) => const SignupScreen(),
        DashboardScreen.route: (_) => const DashboardScreen(),
        JobListScreen.route: (_) => const JobListScreen(),
        ApplicationsScreen.route: (_) => const ApplicationsScreen(),
        ProfileScreen.route: (_) => const ProfileScreen(),
        ResumeUploadScreen.route: (_) => const ResumeUploadScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == JobDetailScreen.route) {
          return MaterialPageRoute(
            builder: (_) => JobDetailScreen(job: settings.arguments as Job),
          );
        }
        return null;
      },
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = context.read<AuthProvider>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init,
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
        return isAuthenticated ? const DashboardScreen() : const LoginScreen();
      },
    );
  }
}

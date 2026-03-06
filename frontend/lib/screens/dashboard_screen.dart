import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_indicator.dart';
import 'applications_screen.dart';
import 'job_detail_screen.dart';
import 'job_list_screen.dart';
import 'profile_screen.dart';
import 'resume_upload_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const route = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<JobProvider>().loadMatchedJobs();
      await context.read<ApplicationProvider>().loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final applicationProvider = context.watch<ApplicationProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - ${user?.email ?? ''}'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await jobProvider.loadMatchedJobs();
          await applicationProvider.loadApplications();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, JobListScreen.route),
                  child: const Text('All Jobs'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, ApplicationsScreen.route),
                  child: const Text('Applications'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, ProfileScreen.route),
                  child: const Text('Profile'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, ResumeUploadScreen.route),
                  child: const Text('Upload Resume'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Matched Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (jobProvider.isLoading) const LoadingIndicator(),
            ...jobProvider.matchedJobs.take(5).map(
                  (job) => JobCard(
                    job: job,
                    onTap: () => Navigator.pushNamed(context, JobDetailScreen.route, arguments: job),
                  ),
                ),
            const SizedBox(height: 16),
            Text(
              'Recent Applications (${applicationProvider.applications.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...applicationProvider.applications.take(5).map(
                  (a) => ListTile(
                    title: Text(a.job?.title ?? 'Job #${a.jobId}'),
                    subtitle: Text(a.job?.company ?? ''),
                    trailing: Text(a.status),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

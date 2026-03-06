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
  Future<void> _loadData() async {
    final jobProvider = context.read<JobProvider>();
    final applicationProvider = context.read<ApplicationProvider>();
    await jobProvider.loadMatchedJobs();
    await applicationProvider.loadApplications();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final applicationProvider = context.watch<ApplicationProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${user?.email.split('@').first ?? 'User'}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final navigator = Navigator.of(context);
              await authProvider.logout();
              if (!mounted) return;
              navigator.pushNamedAndRemoveUntil('/login', (_) => false);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x220F766E),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child:
                        Icon(Icons.work_history_rounded, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Track jobs, generate AI docs, and apply faster.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () =>
                      Navigator.pushNamed(context, JobListScreen.route),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('All Jobs'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      Navigator.pushNamed(context, ApplicationsScreen.route),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Applications'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      Navigator.pushNamed(context, ProfileScreen.route),
                  icon: const Icon(Icons.person_outline_rounded),
                  label: const Text('Profile'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      Navigator.pushNamed(context, ResumeUploadScreen.route),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Upload Resume'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Matched Jobs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (jobProvider.isLoading) const LoadingIndicator(),
            ...jobProvider.matchedJobs.take(5).map(
                  (job) => JobCard(
                    job: job,
                    onTap: () => Navigator.pushNamed(
                        context, JobDetailScreen.route,
                        arguments: job),
                  ),
                ),
            const SizedBox(height: 16),
            Text(
              'Recent Applications (${applicationProvider.applications.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...applicationProvider.applications.take(5).map(
                  (a) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.assignment_turned_in_outlined),
                      title: Text(a.job?.title ?? 'Job #${a.jobId}'),
                      subtitle: Text(a.job?.company ?? ''),
                      trailing: Text(
                        a.status,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

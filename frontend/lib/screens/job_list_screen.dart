import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/job_provider.dart';
import '../widgets/error_widget.dart';
import '../widgets/job_card.dart';
import '../widgets/loading_indicator.dart';
import 'job_detail_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  static const route = '/jobs';

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<JobProvider>().loadJobs());
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(hintText: 'Search jobs (python, backend...)'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.read<JobProvider>().loadJobs(query: _queryController.text.trim()),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          if (provider.isLoading) const Expanded(child: LoadingIndicator()),
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: ErrorMessage(message: provider.error!),
            ),
          if (!provider.isLoading)
            Expanded(
              child: ListView.builder(
                itemCount: provider.jobs.length,
                itemBuilder: (_, index) {
                  final job = provider.jobs[index];
                  return JobCard(
                    job: job,
                    onTap: () => Navigator.pushNamed(context, JobDetailScreen.route, arguments: job),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

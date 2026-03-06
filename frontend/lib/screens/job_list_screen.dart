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
  final _locationController = TextEditingController();
  final _sourceController = TextEditingController();

  Future<void> _loadJobs() async {
    await context.read<JobProvider>().loadJobs(
          query: _queryController.text.trim().isEmpty
              ? null
              : _queryController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          source: _sourceController.text.trim().isEmpty
              ? null
              : _sourceController.text.trim(),
        );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadJobs();
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _locationController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    hintText: 'Search by role (python, backend...)',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: 'Location',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _sourceController,
                        decoration: const InputDecoration(
                          hintText: 'Source (lever, greenhouse...)',
                          prefixIcon: Icon(Icons.source_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loadJobs,
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Apply Filters'),
                  ),
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
                    onTap: () => Navigator.pushNamed(
                        context, JobDetailScreen.route,
                        arguments: job),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

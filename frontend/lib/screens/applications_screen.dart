import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/application_provider.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_indicator.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  static const route = '/applications';

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ApplicationProvider>().loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Applications')),
      body: provider.isLoading
          ? const LoadingIndicator()
          : provider.error != null
              ? ErrorMessage(message: provider.error!)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.applications.length,
                  itemBuilder: (_, index) {
                    final app = provider.applications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.assignment_turned_in_rounded),
                        title: Text(app.job?.title ?? 'Job #${app.jobId}'),
                        subtitle: Text(app.job?.company ?? ''),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            app.status,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

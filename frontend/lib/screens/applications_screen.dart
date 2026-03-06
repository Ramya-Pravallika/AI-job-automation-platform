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
    Future.microtask(() => context.read<ApplicationProvider>().loadApplications());
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
                  itemCount: provider.applications.length,
                  itemBuilder: (_, index) {
                    final app = provider.applications[index];
                    return ListTile(
                      title: Text(app.job?.title ?? 'Job #${app.jobId}'),
                      subtitle: Text(app.job?.company ?? ''),
                      trailing: Text(app.status),
                    );
                  },
                ),
    );
  }
}

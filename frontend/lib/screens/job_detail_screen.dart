import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../providers/application_provider.dart';
import '../providers/job_provider.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.job});

  static const route = '/job-detail';
  final Job job;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _busy = false;

  Future<void> _generateCoverLetter() async {
    setState(() => _busy = true);
    try {
      final text = await context.read<JobProvider>().generateCoverLetter(widget.job.id);
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Generated Cover Letter'),
          content: SingleChildScrollView(child: Text(text)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _autoApply() async {
    setState(() => _busy = true);
    try {
      await context.read<ApplicationProvider>().autoApply(widget.job.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Auto-apply queued')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(job.company, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(job.location ?? 'Unknown location'),
            const SizedBox(height: 12),
            Text(job.description ?? 'No description available.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _busy ? null : _generateCoverLetter,
              child: const Text('Generate AI Cover Letter'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _busy ? null : _autoApply,
              child: const Text('Apply Automatically'),
            ),
          ],
        ),
      ),
    );
  }
}

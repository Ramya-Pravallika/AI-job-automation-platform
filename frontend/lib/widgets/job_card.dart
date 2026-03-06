import 'package:flutter/material.dart';

import '../models/job.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, this.onTap});

  final Job job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(job.title),
        subtitle: Text('${job.company} • ${job.location ?? 'Unknown'}'),
        trailing: job.matchScore != null ? Text('${(job.matchScore! * 100).toStringAsFixed(0)}%') : null,
        onTap: onTap,
      ),
    );
  }
}

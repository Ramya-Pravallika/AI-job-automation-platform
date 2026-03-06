import 'package:flutter/material.dart';

import '../models/job.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, this.onTap});

  final Job job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.business_center_outlined),
        ),
        title: Text(
          job.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${job.company} - ${job.location ?? 'Unknown'}'),
        trailing: job.matchScore != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(job.matchScore! * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

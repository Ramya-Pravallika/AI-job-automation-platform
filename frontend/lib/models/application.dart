import 'job.dart';

class Application {
  final int id;
  final int userId;
  final int jobId;
  final String status;
  final String? coverLetter;
  final DateTime? appliedAt;
  final Job? job;

  Application({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.status,
    this.coverLetter,
    this.appliedAt,
    this.job,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      jobId: json['job_id'] as int,
      status: json['status'] as String,
      coverLetter: json['cover_letter'] as String?,
      appliedAt: json['applied_at'] != null ? DateTime.tryParse(json['applied_at']) : null,
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
    );
  }
}

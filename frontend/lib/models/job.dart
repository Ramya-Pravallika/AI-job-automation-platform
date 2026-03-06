class Job {
  final int id;
  final String title;
  final String company;
  final String? location;
  final String? description;
  final String? salary;
  final String? source;
  final String? applyUrl;
  final DateTime? createdAt;
  final double? matchScore;

  Job({
    required this.id,
    required this.title,
    required this.company,
    this.location,
    this.description,
    this.salary,
    this.source,
    this.applyUrl,
    this.createdAt,
    this.matchScore,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String?,
      description: json['description'] as String?,
      salary: json['salary'] as String?,
      source: json['source'] as String?,
      applyUrl: json['apply_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      matchScore: (json['match_score'] as num?)?.toDouble(),
    );
  }
}

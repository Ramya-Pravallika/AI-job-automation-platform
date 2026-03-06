import '../models/job.dart';
import 'api_service.dart';

class JobService {
  JobService(this._apiService);

  final ApiService _apiService;

  Future<List<Job>> getJobs(
      {String? query, String? location, String? source}) async {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) params['query'] = query;
    if (location != null && location.isNotEmpty) params['location'] = location;
    if (source != null && source.isNotEmpty) params['source'] = source;

    final response = await _apiService.get('/jobs',
        query: params.isEmpty ? null : params, auth: false);
    return (response as List)
        .map((e) => Job.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Job>> getMatchedJobs() async {
    final response = await _apiService.get('/jobs/matched');
    return (response as List)
        .map((e) => Job.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> generateCoverLetter(int jobId) async {
    final response = await _apiService
        .post('/ai/generate-cover-letter', body: {'job_id': jobId});
    return (response as Map<String, dynamic>)['cover_letter'] as String;
  }
}

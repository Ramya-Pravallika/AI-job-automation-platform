import '../models/application.dart';
import 'api_service.dart';

class ApplicationService {
  ApplicationService(this._apiService);

  final ApiService _apiService;

  Future<List<Application>> getApplications() async {
    final response = await _apiService.get('/applications');
    return (response as List).map((e) => Application.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> autoApply(int jobId) async {
    await _apiService.post('/applications/auto-apply', body: {'job_id': jobId});
  }

  Future<void> applyManual(int jobId, {String? coverLetter}) async {
    await _apiService.post('/applications/apply', body: {'job_id': jobId, 'cover_letter': coverLetter});
  }
}

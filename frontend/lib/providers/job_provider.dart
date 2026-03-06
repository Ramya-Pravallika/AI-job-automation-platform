import 'package:flutter/material.dart';

import '../models/job.dart';
import '../services/job_service.dart';

class JobProvider extends ChangeNotifier {
  JobProvider(this._jobService);

  final JobService _jobService;

  List<Job> jobs = [];
  List<Job> matchedJobs = [];
  bool isLoading = false;
  String? error;

  Future<void> loadJobs(
      {String? query, String? location, String? source}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      jobs = await _jobService.getJobs(
          query: query, location: location, source: source);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMatchedJobs() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      matchedJobs = await _jobService.getMatchedJobs();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> generateCoverLetter(int jobId) async {
    return _jobService.generateCoverLetter(jobId);
  }
}

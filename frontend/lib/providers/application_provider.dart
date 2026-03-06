import 'package:flutter/material.dart';

import '../models/application.dart';
import '../services/application_service.dart';

class ApplicationProvider extends ChangeNotifier {
  ApplicationProvider(this._applicationService);

  final ApplicationService _applicationService;

  List<Application> applications = [];
  bool isLoading = false;
  String? error;

  Future<void> loadApplications() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      applications = await _applicationService.getApplications();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> autoApply(int jobId) async {
    await _applicationService.autoApply(jobId);
    await loadApplications();
  }
}

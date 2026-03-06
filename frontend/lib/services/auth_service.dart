import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  AuthService(this._apiService);

  final ApiService _apiService;

  Future<void> signup(String email, String password) async {
    final response = await _apiService.post(
      '/auth/signup',
      auth: false,
      body: {'email': email, 'password': password},
    );
    await _apiService.saveToken(response['access_token'] as String);
  }

  Future<void> login(String email, String password) async {
    final response = await _apiService.post(
      '/auth/login',
      auth: false,
      body: {'email': email, 'password': password},
    );
    await _apiService.saveToken(response['access_token'] as String);
  }

  Future<User> getMe() async {
    final response = await _apiService.get('/users/me');
    return User.fromJson(response as Map<String, dynamic>);
  }

  Future<UserProfile> saveProfile(UserProfile profile,
      {required bool isUpdate}) async {
    final response = isUpdate
        ? await _apiService.put('/users/profile', body: profile.toJson())
        : await _apiService.post('/users/profile', body: profile.toJson());
    return UserProfile.fromJson(response as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _apiService.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }
}

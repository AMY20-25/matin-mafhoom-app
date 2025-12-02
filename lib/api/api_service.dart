#lib/api/api_service.dart

import 'package:dio/dio.dart';
import 'package:matin_mafhoom/config.dart';
import 'package:matin_mafhoom/services/token_service.dart';

class ApiService {
  // 1. Create a Dio instance
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: serverUrl, // Example: http://10.0.2.2:8000/api/v1
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // 2. Private constructor
  ApiService._privateConstructor() {
    _addInterceptors();
  }

  // 3. Singleton instance
  static final ApiService _instance = ApiService._privateConstructor();
  factory ApiService() => _instance;

  // 4. Interceptor setup
  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // --- This runs BEFORE every request ---
          // Get the token from secure storage
          final token = await TokenService.getToken();
          if (token != null) {
            // Add the token to the header
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Continue with the request
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // --- You can handle global errors here ---
          // For example, if a 401 Unauthorized error occurs, log the user out.
          if (e.response?.statusCode == 401) {
            print("Token expired or invalid. Logging out.");
            TokenService.clearToken();
            // Here you would navigate the user to the login screen
          }
          return handler.next(e);
        },
      ),
    );
  }

  // --- API Methods (Refactored) ---

  // 🟩 Health Check
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get("/health");
      return response.statusCode == 200 && response.data?['status'] == 'ok';
    } catch (e) {
      print("❌ Error in checkHealth(): $e");
      return false;
    }
  }

  // 🟨 Authentication
  Future<String?> login(String phone, String otp) async {
    try {
      // Use FormData for OAuth2PasswordRequestForm
      final formData = FormData.fromMap({
        'username': phone, // Mapped to phone
        'password': otp,   // Mapped to otp
      });

      final response = await _dio.post(
        "/auth/token",
        data: formData,
      );

      if (response.statusCode == 200 && response.data?['access_token'] != null) {
        final token = response.data['access_token'];
        // Save the token immediately after a successful login
        await TokenService.saveToken(token);
        return token;
      }
      return null;
    } catch (e) {
      print("❌ Error in login(): $e");
      return null;
    }
  }

  // Example of a protected endpoint call
  // 🟪 Get My Reservations
  Future<void> getMyReservations() async {
    try {
      // No need to set token manually, the interceptor handles it!
      final response = await _dio.get("/reservations/me");
      
      // Now you can process the list of reservations
      print("My Reservations: ${response.data}");

    } catch (e) {
      print("❌ Error in getMyReservations(): $e");
    }
  }
}

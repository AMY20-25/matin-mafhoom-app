import 'package:dio/dio.dart';
import 'package:matin_mafhoom/config.dart';
import 'package:matin_mafhoom/models/reservation_model.dart'; // Import the new model
import 'package:matin_mafhoom/services/token_service.dart';

// A modern, singleton ApiService using Dio and Interceptors.
class ApiService {
  // 1. Create a Dio instance with base options
  final Dio _dio;

  // 2. Private constructor
  ApiService._privateConstructor()
      : _dio = Dio(
          BaseOptions(
            baseUrl: serverUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
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
          final token = await TokenService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            print("ApiService: Unauthorized. Clearing token.");
            TokenService.clearToken();
          }
          return handler.next(e);
        },
      ),
    );
  }

  // --- API Methods ---

  Future<bool> requestOtp(String phoneNumber) async {
    try {
      final response = await _dio.post(
        "/auth/request-otp",
        data: {"phone_number": phoneNumber},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error in requestOtp(): $e");
      return false;
    }
  }

  Future<String?> login(String phone, String otp) async {
    try {
      final formData = FormData.fromMap({'username': phone, 'password': otp});
      final response = await _dio.post("/auth/token", data: formData);

      if (response.statusCode == 200 && response.data?['access_token'] != null) {
        final token = response.data['access_token'];
        await TokenService.saveToken(token);
        return token;
      }
      return null;
    } catch (e) {
      print("❌ Error in login(): $e");
      return null;
    }
  }

  Future<dynamic> getMyProfile() async {
    try {
      final response = await _dio.get("/auth/users/me");
      return response.data;
    } catch (e) {
      print("❌ Error in getMyProfile(): $e");
      return null;
    }
  }

  // --- NEW: Reservation Methods ---

  /// Fetches the current user's reservations
  Future<List<Reservation>> getMyReservations() async {
    try {
      final response = await _dio.get("/reservations/me");
      final List<dynamic> data = response.data;
      return data.map((json) => Reservation.fromJson(json)).toList();
    } catch (e) {
      print("❌ Error in getMyReservations(): $e");
      return [];
    }
  }

  /// Creates a new reservation
  Future<bool> createReservation(DateTime date, String serviceType) async {
    try {
      // The backend now reads user_id from the token, so we don't send it.
      final response = await _dio.post(
        "/reservations/",
        data: {
          'service_type': serviceType,
          'date': date.toIso8601String(),
        },
      );
      return response.statusCode == 201; // 201 Created
    } catch (e) {
      print("❌ Error in createReservation(): $e");
      return false;
    }
  }
}


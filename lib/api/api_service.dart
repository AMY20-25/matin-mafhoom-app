import 'package:dio/dio.dart';
import 'package:matin_mafhoom/config.dart';
import 'package:matin_mafhoom/models/reservation_model.dart';
import 'package:matin_mafhoom/services/token_service.dart';

class ApiService {
  final Dio _dio;

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

  static final ApiService _instance = ApiService._privateConstructor();
  factory ApiService() => _instance;

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

  // --- Auth Methods ---
  Future<bool> requestOtp(String phoneNumber) async {
    try {
      final response = await _dio.post("/auth/request-otp", data: {"phone_number": phoneNumber});
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

  // --- User Profile Methods ---
  Future<dynamic> getMyProfile() async {
    try {
      final response = await _dio.get("/auth/users/me");
      return response.data;
    } catch (e) {
      print("❌ Error in getMyProfile(): $e");
      return null;
    }
  }

  Future<bool> updateMyProfile({String? firstName, String? lastName}) async {
    try {
      final response = await _dio.patch(
        "/users/me",
        data: {
          "first_name": firstName,
          "last_name": lastName,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error in updateMyProfile(): $e");
      return false;
    }
  }

  // --- Reservation Methods ---
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

  Future<bool> createReservation(DateTime date, String serviceType) async {
    try {
      final response = await _dio.post(
        "/reservations/",
        data: {
          'service_type': serviceType,
          'date': date.toIso8601String(),
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      print("❌ Error in createReservation(): $e");
      return false;
    }
  }
}


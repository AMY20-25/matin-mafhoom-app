import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:matin_mafhoom/config.dart';
import 'package:matin_mafhoom/models/reservation_model.dart';
import 'package:matin_mafhoom/models/referral_model.dart';
import 'package:matin_mafhoom/services/token_service.dart';

/// A modern, singleton ApiService using Dio and Interceptors for all network requests.
class ApiService {
  final Dio _dio;

  // Private constructor to implement the singleton pattern.
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

  // The single, static instance of the ApiService.
  static final ApiService _instance = ApiService._privateConstructor();
  
  // Factory constructor to return the singleton instance.
  factory ApiService() => _instance;

  // Sets up interceptors to automatically handle tokens and errors.
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
            print("ApiService: Unauthorized access. Clearing token.");
            TokenService.clearToken();
          }
          return handler.next(e);
        },
      ),
    );
  }

  // --- Authentication Methods ---

  /// Requests an OTP code from the backend for the given phone number.
  Future<bool> requestOtp(String phoneNumber) async {
    try {
      final response = await _dio.post("/auth/request-otp", data: {"phone_number": phoneNumber});
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error in requestOtp(): $e");
      return false;
    }
  }

  /// Verifies the OTP and logs the user in, returning an access token.
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

  /// Fetches the profile of the currently authenticated user.
  Future<dynamic> getMyProfile() async {
    try {
      final response = await _dio.get("/auth/users/me");
      return response.data;
    } catch (e) {
      print("❌ Error in getMyProfile(): $e");
      return null;
    }
  }

  /// Updates the profile of the currently authenticated user.
  Future<bool> updateMyProfile({String? firstName, String? lastName, DateTime? birthDate}) async {
    try {
      final response = await _dio.patch(
        "/users/me",
        data: {
          "first_name": firstName,
          "last_name": lastName,
          "birth_date": birthDate != null ? DateFormat('yyyy-MM-dd').format(birthDate) : null,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error in updateMyProfile(): $e");
      return false;
    }
  }
  
  // --- Referral Methods ---

  /// Fetches the referral information for the current user.
  Future<dynamic> getMyReferralInfo() async {
    try {
      final response = await _dio.get("/referrals/me");
      return response.data;
    } catch (e) {
      print("❌ Error in getMyReferralInfo(): $e");
      return null;
    }
  }

  // --- Reservation Methods ---

  /// Fetches all reservations for the current user.
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

  /// Creates a new reservation for the current user.
  Future<bool> createReservation(DateTime date, String serviceType) async {
    try {
      final response = await _dio.post(
        "/reservations/",
        data: {
          'service_type': serviceType,
          'date': date.toIso8601String(),
        },
      );
      return response.statusCode == 201; // HTTP 201 Created
    } catch (e) {
      print("❌ Error in createReservation(): $e");
      return false;
    }
  }
}


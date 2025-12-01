import 'package:dio/dio.dart';
import 'package:matin_mafhoom/config.dart';

class ApiService {
  // Singleton Dio
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: serverUrl, // مثال: https://api.matinmafhoom.com
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // ---------------------------------------------------------
  // 🟪 انتخاب توکن به صورت داینامیک
  // ---------------------------------------------------------
  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ---------------------------------------------------------
  // 🟩 تست سرور /health
  // ---------------------------------------------------------
  static Future<bool> checkHealth() async {
    try {
      final response = await _dio.get("/health");

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data["status"] == "ok") {
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error in checkHealth(): $e");
      return false;
    }
  }

  // ---------------------------------------------------------
  // 🟦 ارسال رزرو
  // ---------------------------------------------------------
  static Future<bool> reserve({
    required String date,
    required String slot,
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        "/reserve",
        data: {
          "date": date,
          "slot": slot,
          "phone": phone,
        },
      );

      if (response.statusCode == 200 &&
          response.data.toString().contains("Reservation saved")) {
        return true;
      }

      if (response.statusCode == 409) {
        return false; // اسلات رزرو شده
      }

      return false;
    } catch (e) {
      print("❌ Error in reserve(): $e");
      return false;
    }
  }

  // ---------------------------------------------------------
  // 🟩 دریافت اسلات‌های رزرو شده
  // ---------------------------------------------------------
  static Future<List<String>> getReservations(String date) async {
    try {
      final response = await _dio.get(
        "/reservations",
        queryParameters: {"date": date},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is List) {
          return data
              .map((e) => e is Map && e['slot'] != null
                  ? e['slot'].toString()
                  : e.toString())
              .toList();
        }

        return <String>[];
      }
      throw Exception("خطای سرور: ${response.statusCode}");
    } catch (e) {
      print("❌ Error in getReservations(): $e");
      return <String>[];
    }
  }

  // ---------------------------------------------------------
  // 🟧 ارسال OTP
  // ---------------------------------------------------------
  static Future<bool> sendOtp(String phone) async {
    try {
      final response = await _dio.post(
        "/send_otp",
        data: {"phone": phone},
      );

      return response.statusCode == 200 &&
          response.data["ok"] == true;
    } catch (e) {
      print("❌ Error in sendOtp(): $e");
      return false;
    }
  }

  // ---------------------------------------------------------
  // 🟨 تأیید OTP + دریافت توکن
  // ---------------------------------------------------------
  static Future<String?> verifyOtp(String phone, String code) async {
    try {
      final response = await _dio.post(
        "/verify_otp",
        data: {"phone": phone, "code": code},
      );

      if (response.statusCode == 200 && response.data["ok"] == true) {
        return response.data["token"];
      }

      return null;
    } catch (e) {
      print("❌ Error in verifyOtp(): $e");
      return null;
    }
  }
}


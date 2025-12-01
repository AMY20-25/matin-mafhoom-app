import '../services/token_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  bool codeSent = false;
  bool loading = false;
  String? errorMessage;

  static const String API_BASE = "https://api.matinmafhoom.ir";

  /// ارسال کد OTP
  Future<void> _sendCode() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        loading = false;
        errorMessage = "شماره موبایل را وارد کنید";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$API_BASE/auth/request_otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone_number": phone}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          codeSent = true;
        });
      } else {
        setState(() {
          errorMessage = data["detail"] ?? "خطا در ارسال کد";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "ارتباط با سرور برقرار نشد";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  /// تأیید کد OTP
  Future<void> _verifyCode() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    final phone = phoneController.text.trim();
    final code = codeController.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      setState(() {
        loading = false;
        errorMessage = "شماره و کد را وارد کنید";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$API_BASE/auth/verify_otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone_number": phone, "otp": code}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final token = data["access_token"];
	await TokenService.saveToken(token);   // ذخیره امن توکن
        Navigator.pushReplacementNamed(context, "/");
      } else {
        setState(() {
          errorMessage = data["detail"] ?? "کد اشتباه است";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "ارتباط با سرور برقرار نشد";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFFFFFFFF);
    const Color blob = Color(0xFF6D60F8);
    const Color button = Color(0xFF6D60F8);
    const Color arrow = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(top: -40, left: -60, child: _CornerBlob(color: blob, size: 220)),
            Positioned(bottom: -50, right: -70, child: _CornerBlob(color: blob, size: 260)),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "شماره موبایل خود را وارد کنید",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: "مثلاً 09123456789"),
                    ),
                    const SizedBox(height: 20),

                    if (!codeSent)
                      ElevatedButton(
                        onPressed: loading ? null : _sendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: button,
                          foregroundColor: arrow,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("ارسال کد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: arrow)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: arrow),
                                ],
                              ),
                      ),

                    if (codeSent) ...[
                      const SizedBox(height: 20),
                      TextField(
                        controller: codeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "کد تأیید را وارد کنید"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: loading ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: button,
                          foregroundColor: arrow,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("تأیید و ورود", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: arrow)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: arrow),
                                ],
                              ),
                      ),
                    ],

                    if (errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ویجت حلال گوشه‌ای
class _CornerBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _CornerBlob({required this.color, required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * 0.45)),
    );
  }
}


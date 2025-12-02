import 'package:flutter/material.dart';
import 'package:matin_mafhoom/api/api_service.dart'; // 1. Import our new ApiService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  
  bool loading = false;
  String? errorMessage;

  // No need for separate codeSent flag, we'll just use one function
  
  /// Verifies the OTP and logs the user in
  Future<void> _login() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    final phone = phoneController.text.trim();
    final code = codeController.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      setState(() {
        loading = false;
        errorMessage = "شماره موبایل و کد را وارد کنید";
      });
      return;
    }

    try {
      // 2. Use the new, clean ApiService method
      final token = await ApiService().login(phone, code);

      if (token != null) {
        // On success, navigate to the home screen
        // The token is already saved by the ApiService
        if (mounted) { // Check if the widget is still in the tree
          Navigator.pushReplacementNamed(context, "/"); 
        }
      } else {
        // ApiService().login returns null on failure
        setState(() {
          errorMessage = "شماره یا کد وارد شده صحیح نیست";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "خطا در ارتباط با سرور";
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Your UI Code - UNCHANGED ---
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
                      "ورود یا ثبت نام", // Updated Title
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: "شماره موبایل (مثلاً 09123456789)"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "کد تأیید ارسال شده"),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: loading ? null : _login, // 3. Use the single _login function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: button,
                        foregroundColor: arrow,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("تأیید و ورود", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: arrow)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: arrow),
                              ],
                            ),
                    ),
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

// --- Your _CornerBlob Widget - UNCHANGED ---
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

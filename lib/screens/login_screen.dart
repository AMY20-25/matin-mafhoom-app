import 'package:flutter/material.dart';
import 'package:matin_mafhoom/api/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  
  bool isCodeSent = false;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  // --- Logic for Requesting OTP ---
  Future<void> _requestOtp() async {
    if (isLoading) return;
    setState(() { isLoading = true; errorMessage = null; successMessage = null; });

    final phone = phoneController.text.trim();
    if (phone.isEmpty || !RegExp(r"^09[0-9]{9}$").hasMatch(phone)) {
      setState(() { isLoading = false; errorMessage = "شماره موبایل معتبر نیست"; });
      return;
    }
    
    final success = await ApiService().requestOtp(phone);

    if (mounted) {
      setState(() {
        isLoading = false;
        if (success) {
          isCodeSent = true;
          successMessage = "کد تایید با موفقیت ارسال شد.";
        } else {
          errorMessage = "خطا در ارسال کد. لطفاً دوباره تلاش کنید.";
        }
      });
    }
  }

  // --- Logic for Verifying OTP and Logging In ---
  Future<void> _verifyAndLogin() async {
    if (isLoading) return;
    setState(() { isLoading = true; errorMessage = null; successMessage = null; });

    final phone = phoneController.text.trim();
    final code = codeController.text.trim();
    if (phone.isEmpty || code.isEmpty) {
      setState(() { isLoading = false; errorMessage = "کد تایید را وارد کنید"; });
      return;
    }

    final token = await ApiService().login(phone, code);

    if (mounted) {
      if (token != null) {
        Navigator.pushReplacementNamed(context, '/'); 
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "کد وارد شده صحیح نیست";
        });
      }
    }
  }

  // --- UI Build Method (Your UI is preserved) ---
  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFFFFFFFF);
    const Color blob = Color(0xFF6D60F8);
    const Color buttonColor = Color(0xFF6D60F8);
    const Color arrowColor = Color(0xFFFFFFFF);

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
                    Text(
                      isCodeSent ? "کد را وارد کنید" : "ورود یا ثبت نام",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      readOnly: isCodeSent,
                      decoration: const InputDecoration(hintText: "شماره موبایل (مثلاً 09123456789)"),
                    ),
                    if (isCodeSent) ...[
                      const SizedBox(height: 20),
                      TextField(
                        controller: codeController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: "کد تأیید ۶ رقمی"),
                      ),
                    ],
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isLoading ? null : (isCodeSent ? _verifyAndLogin : _requestOtp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: arrowColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(isCodeSent ? "تأیید و ورود" : "ارسال کد", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward),
                              ],
                            ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                      ),
                    if (successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(successMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.green)),
                      ),
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

class _CornerBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _CornerBlob({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * 0.45)),
    );
  }
}


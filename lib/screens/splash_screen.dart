import 'package:flutter/material.dart';
import 'package:matin_mafhoom/services/token_service.dart';
// We don't need ApiService here as we'll just check the token

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for a short moment to show the splash screen
    await Future.delayed(const Duration(milliseconds: 500));

    // Check for the token
    final token = await TokenService.getToken();
    
    if (!mounted) return; // Check if the widget is still in the tree

    if (token != null) {
      // If token exists, go to home
      Navigator.pushReplacementNamed(context, '/');
    } else {
      // If not, go to the welcome screen
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    // A simple splash screen with a logo and a loader
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can put your logo here, for example:
            // Image.asset('assets/images/logo1.png', width: 150),
            Text("Matin Mafhoom", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("در حال بارگذاری..."),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart'; // 1. Import the new splash screen
import 'theme.dart';

// No need for heavy async operations in main anymore
void main() {
  runApp(const MatinApp());
}

class MatinApp extends StatelessWidget {
  const MatinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matin Mafhoom',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // 2. Always start with the splash screen
      initialRoute: '/splash', 
      routes: {
        // 3. Add the splash screen to the routes
        '/splash': (context) => const SplashScreen(), 
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/': (context) => const HomeScreen(),
        '/booking': (context) => const BookingScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/partners': (context) => const PartnersScreen(),
        '/offers': (context) => const OffersScreen(),
        '/liveModel': (context) => const LiveModelScreen(),
      },
    );
  }
}

// --- Placeholder screens can remain unchanged ---

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("صفحه گالری")));
  }
}
class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("صفحه همکاران")));
  }
}
class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("صفحه تخفیف‌ها")));
  }
}

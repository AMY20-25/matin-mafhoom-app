import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- Screen Imports ---
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/profile_screen.dart'; 
import 'screens/live_model_screen.dart'; 

// --- Config/Theme Imports ---
import 'theme.dart';

void main() {
  initializeDateFormatting('fa_IR', null).then((_) {
    runApp(const MatinApp());
  });
}

class MatinApp extends StatelessWidget {
  const MatinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matin Mafhoom',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      
      initialRoute: '/splash',
      
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/': (context) => const ShellScreen(),
        '/booking': (context) => const BookingScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/partners': (context) => const PartnersScreen(),
        '/offers': (context) => const OffersScreen(),
        '/liveModel': (context) => LiveModelScreen(),
      },
    );
  }
}

// --- Placeholder Screens (Corrected) ---
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("گالری")), 
      body: const Center(child: Text("صفحه گالری"))
    );
  }
}

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("همکاران")), 
      body: const Center(child: Text("صفحه همکاران"))
    );
  }
}

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تخفیف ها")), 
      body: const Center(child: Text("صفحه تخفیف‌ها"))
    );
  }
}


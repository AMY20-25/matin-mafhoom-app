import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'theme.dart';
import 'services/token_service.dart';
import 'screens/live_model_screen.dart';
import 'api/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔵 تست اتصال به سرور FastAPI → /health
  final health = await ApiService.checkHealth();
  print("🔍 HEALTH CHECK RESULT → $health");

  // 🔵 بررسی وجود توکن ذخیره‌شده
  final token = await TokenService.getToken();

  runApp(
    MatinApp(
      initialRoute: token != null ? '/' : '/welcome',
    ),
  );
}

class MatinApp extends StatelessWidget {
  final String initialRoute;
  const MatinApp({required this.initialRoute, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matin Mafhoom',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: initialRoute,
      routes: {
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

// صفحات خالی برای تست ناوبری
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("صفحه گالری")),
    );
  }
}

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("صفحه همکاران")),
    );
  }
}

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("صفحه تخفیف‌ها")),
    );
  }
}


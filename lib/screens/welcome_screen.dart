import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF6D60F8);     // پس‌زمینه خوشامد
    const Color blob = Color(0xFF5F52F0);   // حلال‌های گوشه‌ای
    const Color button = Color(0xFFFFFFFF); // دکمه ورود
    const Color arrow = Color(0xFF7B6FF8);  // فلش روی دکمه

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // حلال بالا-چپ
            Positioned(
              top: -40,
              left: -60,
              child: _CornerBlob(color: blob, size: 220, flip: false),
            ),
            // حلال پایین-راست
            Positioned(
              bottom: -50,
              right: -70,
              child: _CornerBlob(color: blob, size: 260, flip: true),
            ),

            // متن وسط صفحه
            Center(
              child: Text(
                "سالن تخصصی داماد متین مفهوم",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // دکمه ورود پایین
            Positioned(
              left: 24,
              right: 24,
              bottom: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: button,
                  foregroundColor: arrow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pushNamed(context, "/login"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "ورود",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: arrow,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: arrow),
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

/// ویجت حلال گوشه‌ای با ClipPath برای فرم ارگانیک
class _CornerBlob extends StatelessWidget {
  final Color color;
  final double size;
  final bool flip;

  const _CornerBlob({
    required this.color,
    required this.size,
    this.flip = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ(flip ? 0.0 : 0.0)
        ..scale(1.0, flip ? -1.0 : 1.0),
      child: ClipPath(
        clipper: _BlobClipper(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.45),
          ),
        ),
      ),
    );
  }
}

class _BlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // مسیر نرم و ارگانیک برای گوشه‌ها
    final Path path = Path();
    path.moveTo(0, size.height * 0.35);
    path.quadraticBezierTo(
      size.width * 0.10, 0,
      size.width * 0.55, 0,
    );
    path.quadraticBezierTo(
      size.width, 0,
      size.width, size.height * 0.45,
    );
    path.quadraticBezierTo(
      size.width * 0.95, size.height,
      size.width * 0.45, size.height,
    );
    path.quadraticBezierTo(
      0, size.height,
      0, size.height * 0.55,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


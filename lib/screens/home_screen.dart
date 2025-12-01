import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // پالت رنگ دقیق
    const Color bg = Color(0xFFFFFFFF);        // سفید
    const Color header = Color(0xFF6D60F8);    // بنفش هدر
    const Color liveModelBtn = Color(0xFF70CFFC); // دکمه مدل زنده
    const Color graphic = Color(0xFFFFC87F);   // گرافیک دیزاین
    const Color uxui = Color(0xFFFFCE5D);      // UX/UI
    const Color program = Color(0xFF5370FF);   // برنامه‌نویسی
    const Color programIcon = Color(0xFF7E94FF); // آیکن برنامه‌نویسی
    const Color testing = Color(0xFF88C300);   // تست
    const Color addressBg = Color(0xFFF1EFFE); // پس‌زمینه آدرس

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // هدر بالا با تیتر راست‌چین و دکمه مدل زنده زیرش
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: header,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // تراز راست
                children: [
                  const Text(
                    "سالن تخصصی داماد متین مفهوم",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, "/liveModel");
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
                    label: const Text("مدل زنده", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: liveModelBtn,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 40),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // گزینه‌های وسط صفحه
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _DashboardItem(title: "گالری", color: graphic, icon: Icons.photo_library, route: "/gallery"),
                  _DashboardItem(title: "رزرو وقت", color: uxui, icon: Icons.calendar_today, route: "/booking"),
                  _DashboardItem(title: "همکاران", color: program, icon: Icons.people, iconColor: programIcon, route: "/partners"),
                  _DashboardItem(title: "تخفیف‌ها", color: testing, icon: Icons.local_offer, route: "/offers"),
                ],
              ),
            ),

            // نمایش آدرس پایین
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: addressBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.location_on, color: header),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "خیابان پاسداران، نبش پاسداران ۱۱، سالن تخصصی داماد متین مفهوم",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// آیتم‌های داشبورد با ناوبری
class _DashboardItem extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final Color? iconColor;
  final String route;

  const _DashboardItem({
    required this.title,
    required this.color,
    required this.icon,
    this.iconColor,
    required this.route,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: iconColor ?? Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


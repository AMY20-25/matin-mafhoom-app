import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFFFFFFFF); // پس‌زمینه سفید
    const Color gallery = Color(0xFF70CFFC); // گالری آنلاین
    const Color graphic = Color(0xFFFFC87F); // گرافیک دیزاین
    const Color uxui = Color(0xFFFFCE5D); // UX/UI
    const Color program = Color(0xFF5370FF); // Programs
    const Color programIcon = Color(0xFF7E94FF); // آیکن برنامه‌نویسی
    const Color testing = Color(0xFF88C300); // Testing

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("داشبورد"),
        backgroundColor: const Color(0xFF6D60F8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _DashboardButton(
              color: gallery,
              icon: Icons.photo_library,
              label: "گالری آنلاین",
              onTap: () => Navigator.pushNamed(context, "/gallery"),
            ),
            _DashboardButton(
              color: graphic,
              icon: Icons.brush,
              label: "گرافیک دیزاین",
              onTap: () {},
            ),
            _DashboardButton(
              color: uxui,
              icon: Icons.design_services,
              label: "UX/UI Design",
              onTap: () {},
            ),
            _DashboardButton(
              color: program,
              icon: Icons.code,
              label: "برنامه‌نویسی",
              iconColor: programIcon,
              onTap: () {},
            ),
            _DashboardButton(
              color: testing,
              icon: Icons.check_circle,
              label: "Testing",
              onTap: () {},
            ),
            _DashboardButton(
              color: const Color(0xFF6D60F8),
              icon: Icons.support_agent,
              label: "مشاوره تخصصی",
              onTap: () => Navigator.pushNamed(context, "/ai"),
            ),
            _DashboardButton(
              color: const Color(0xFF6D60F8),
              icon: Icons.people,
              label: "همکاران",
              onTap: () => Navigator.pushNamed(context, "/partners"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF6D60F8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "خانه"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "اعلان‌ها"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "ذخیره‌ها"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "پروفایل"),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, "/");
              break;
            case 1:
              Navigator.pushNamed(context, "/offers");
              break;
            case 2:
              Navigator.pushNamed(context, "/saved");
              break;
            case 3:
              Navigator.pushNamed(context, "/profile");
              break;
          }
        },
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _DashboardButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor ?? Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

// --- Color Palette ---
const Color bgColor = Color(0xFFFFFFFF);
const Color primaryHeader = Color(0xFF6D60F8);
const Color onlineConsultantBtn = Color(0xFF70CFFC);
const Color bookingBtn = Color(0xFFFFCE5D);
const Color galleryBtn = Color(0xFFFFC87F);
const Color partnersBtn = Color(0xFF5370FF);
const Color partnersIcon = Color(0xFF7E94FF);
const Color discountsBtn = Color(0xFF88C300);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen no longer has its own Scaffold.
    // It will be displayed inside the ShellScreen's body.
    return Scaffold( // We add a Scaffold here to have a background color and app bar
      appBar: AppBar(
        title: const Text("داشبورد"),
        backgroundColor: primaryHeader,
        automaticallyImplyLeading: false, // Removes the back button
      ),
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          _buildDashboardGrid(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: primaryHeader,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "سالن تخصصی داماد متین مفهوم",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () { /* TODO: Navigate to online consultation */ },
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              label: const Text("مشاور آنلاین", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: onlineConsultantBtn,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _DashboardCard(title: "گالری", color: galleryBtn, icon: Icons.photo_library, route: "/gallery"),
          _DashboardCard(title: "رزرو وقت", color: bookingBtn, icon: Icons.calendar_today, route: "/booking"),
          _DashboardCard(title: "همکاران", color: partnersBtn, icon: Icons.people, iconColor: partnersIcon, route: "/partners"),
          _DashboardCard(title: "تخفیف‌ها", color: discountsBtn, icon: Icons.local_offer, route: "/offers"),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final Color? iconColor;
  final String route;

  const _DashboardCard({
    required this.title,
    required this.color,
    required this.icon,
    this.iconColor,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 45, color: iconColor ?? Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

// --- Placeholder Screens ---
// We remove 'const' because AppBar is not a const constructor.
final Widget vipScreen = Scaffold(appBar: AppBar(title: const Text("VIP")), body: const Center(child: Text("صفحه VIP")));
final Widget contactScreen = Scaffold(appBar: AppBar(title: const Text("ارتباط با ما")), body: const Center(child: Text("صفحه ارتباط با ما")));

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  // --- THE FINAL FIX ---
  // This list can no longer be 'const' because its items are not 'const'.
  final List<Widget> _pages = <Widget>[
    const HomeScreen(), // HomeScreen can be const if its constructor is
    vipScreen,
    contactScreen,
    const ProfileScreen(), // ProfileScreen can be const
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bottomNavBg = Colors.white;
    const Color selectedItemColor = Color(0xFF6d60f8);
    const Color unselectedItemColor = Colors.grey;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'خانه'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border_outlined), activeIcon: Icon(Icons.star), label: 'VIP'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_outlined), activeIcon: Icon(Icons.support_agent), label: 'ارتباط با ما'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'پروفایل'),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: bottomNavBg,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}


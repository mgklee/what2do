import 'package:flutter/material.dart';
import 'tab1/tab1.dart';
import 'tab2/tab2.dart';
import 'tab3/tab3.dart';
import 'tab4/tab4.dart';
import 'login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppEntryPoint(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        splashColor: Colors.transparent, // Remove ripple effect
        highlightColor: Colors.transparent, // Remove highlight effect
      ),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  @override
  _AppEntryPointState createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool isLoggedIn = false; // Tracks if the user is logged in

  @override
  Widget build(BuildContext context) {
    return isLoggedIn
      ? HomePage( // Navigate to main app after login
        onLogout: () {
          setState(() {
            isLoggedIn = false; // Logout handler
          });
        },
      )
      : LoginScreen();
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onLogout; // Callback for logout

  const HomePage({required this.onLogout, super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Default selected tab index

  final List<String> _titles = [
    'Home',
    'Timetable',
    'Friends',
    'Mypage',
  ];

  final List<Widget> tabs = [
    Tab1(),
    Tab2(),
    Tab3(),
    Tab4(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex], // Update title based on current index
          style: const TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: buildBottomNavigationItems(),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0, // Optional: Remove shadow below the bar
      ),
    );
  }

  List<BottomNavigationBarItem> buildBottomNavigationItems() {
    return [
      BottomNavigationBarItem(
        icon: _buildIcon(0, Icons.home),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: _buildIcon(1, Icons.calendar_today),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: _buildIcon(2, Icons.group),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: _buildIcon(3, Icons.person),
        label: '',
      ),
    ];
  }

  Widget _buildIcon(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF18C971) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : const Color(0xFFBDBDBD),
      ),
    );
  }
}

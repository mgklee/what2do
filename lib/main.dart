import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'login_screen.dart';
import 'tab1/tab1.dart';
import 'tab2/tab2.dart';
import 'tab3/tab3.dart';
import 'tab4/tab4.dart';

void main() {
  // Flutter SDK 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Kakao SDK 초기화 (Native App Key)
  KakaoSdk.init(nativeAppKey: '0f0975de364e8bf139886b4cf89df7d9');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppEntryPoint(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pretendard',
        highlightColor: Colors.transparent, // Remove highlight effect
        scaffoldBackgroundColor: Colors.white,
        splashColor: Colors.transparent, // Remove ripple effect
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
  late Map<String, dynamic> userInfo; // Store backend response data

  // Simulate login logic (can be replaced with real authentication logic)
  void _onLoginSuccess() {
    setState(() {
      isLoggedIn = true;
    });
  }

  void _onBackendResponse(Map<String, dynamic> response) {
    setState(() {
      userInfo = response;
    });
  }

  void _onLogout() {
    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn
        ? HomePage(
      userInfo: userInfo,
      onLogout: _onLogout, // Pass logout callback to the main app screen
    )
        : LoginScreen(
      onLoginSuccess: _onLoginSuccess, // Pass login success callback to login screen
      onBackendResponse: _onBackendResponse, // Handle backend response
    );
  }
}

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userInfo; // Store backend response data
  final VoidCallback onLogout; // Callback for logout

  const HomePage({
    required this.userInfo,
    required this.onLogout,
    super.key
  });

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

  late List<Widget> tabs = [
    Tab1(userInfo: widget.userInfo),
    Tab2(userInfo: widget.userInfo),
    Tab3(userInfo: widget.userInfo),
    Tab4(userInfo: widget.userInfo, onLogout: widget.onLogout),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Custom height for the AppBar
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 15, left: 5),
            child: Text(
              _titles[_currentIndex], // Update title based on current index
              style: const TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
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

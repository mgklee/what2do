import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'login_screen.dart';
import 'tabs/tab1.dart';
import 'tabs/tab2.dart';
import 'tabs/tab3.dart';
import 'tabs/tab4.dart';
import 'splash_screen.dart';

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
  bool showSplashScreen = true; // 스플래시 화면 표시 여부
  final String baseUrl = 'http://172.10.7.57:8000';
  late Map<String, dynamic> userInfo; // Store backend response data

  @override
  void initState() {
    super.initState();

    // 2초 후 스플래시 화면 숨김
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        showSplashScreen = false; // 스플래시 화면 종료
      });
    });
  }

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
    if (showSplashScreen) {
      return SplashScreen(); // 스플래시 화면
    }

    return isLoggedIn
    ? HomePage(
      baseUrl: baseUrl,
      userInfo: userInfo,
      onLogout: _onLogout, // Pass logout callback to the main app screen
    )
    : LoginScreen(
      baseUrl: baseUrl,
      onLoginSuccess: _onLoginSuccess, // Pass login success callback to login screen
      onBackendResponse: _onBackendResponse, // Handle backend response
    );
  }
}

class HomePage extends StatefulWidget {
  final String baseUrl;
  final Map<String, dynamic> userInfo; // Store backend response data
  final VoidCallback onLogout; // Callback for logout

  const HomePage({
    required this.baseUrl,
    required this.userInfo,
    required this.onLogout,
    super.key
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Default selected tab index

  late List<Widget> tabs = [
    Tab1(baseUrl: widget.baseUrl, userInfo: widget.userInfo),
    Tab2(baseUrl: widget.baseUrl, userInfo: widget.userInfo),
    Tab3(baseUrl: widget.baseUrl, userInfo: widget.userInfo),
    Tab4(baseUrl: widget.baseUrl, userInfo: widget.userInfo, onLogout: widget.onLogout),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Custom height for the AppBar
        child: const SizedBox(height: 60),
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
        color: isSelected ? Color(0xFF18C971) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : const Color(0xFFBDBDBD),
      ),
    );
  }
}

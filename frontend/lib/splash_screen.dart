import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; // 이미지 초기 투명도

  @override
  void initState() {
    super.initState();

    // 애니메이션 시작
    Timer(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // 투명도를 1로 설정하여 이미지가 나타나도록 함
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0FD380), // 초록색 배경
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity, // 투명도 값
          duration: Duration(seconds: 1), // 애니메이션 지속 시간
          curve: Curves.easeIn, // 부드러운 나타남 효과
          child: Image.asset(
            'assets/splash.png', // 스플래시 이미지 경로
            width: 200, // 이미지 크기
            height: 200,
          ),
        ),
      ),
    );
  }
}

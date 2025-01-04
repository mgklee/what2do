import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'dart:convert';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  LoginScreen({required this.onLoginSuccess, super.key});

  // Google Sign-In 설정
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
    "358946647934-bmir594d3nbdj7mcgradov4ogrd74p1b.apps.googleusercontent.com",
    scopes: [
      'email', // Access the user's email
      'https://www.googleapis.com/auth/userinfo.profile', // Access profile info
    ],
  );

  // Google 로그인 처리
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        print('Logged in as: ${account.displayName}');
        print('Email: ${account.email}');
        onLoginSuccess();
      } else {
        print('Sign-In aborted by user.');
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
    }
  }

  // Kakao 로그인 처리
  Future<void> _handleKakaoSignIn() async {
    try {
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        // 카카오톡 앱을 통한 로그인
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          print('Logged in with KakaoTalk: ${token.accessToken}');
          await _sendTokenToBackend(token.accessToken); // Send token to backend
          onLoginSuccess();
        } catch (error) {
          print('Error during KakaoTalk Login: $error');
        }
      } else {
        // 카카오 계정을 통한 로그인 (웹 뷰)
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('Logged in with KakaoAccount: ${token.accessToken}');
          await _sendTokenToBackend(token.accessToken); // Send token to backend
          onLoginSuccess();
        } catch (error) {
          print('Error during KakaoAccount Login: $error');
        }
      }
    } catch (error) {
      print('Error during Kakao Login: $error');
    }
  }

  Future<void> _sendTokenToBackend(String accessToken) async {
    final url = Uri.parse(
        "http://172.10.7.56:8000/users/login"); // Your backend endpoint
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"oauth_token": accessToken}),
    );

    if (response.statusCode == 200) {
      print("Login successful: ${jsonDecode(response.body)}");
    } else {
      print("Login failed: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(80.0), // Custom height for the AppBar
      //   child: Padding(
      //     padding: const EdgeInsets.all(10.0), // Add padding
      //     child: AppBar(
      //       title: const Text(
      //         'Login',
      //         style: TextStyle(fontWeight: FontWeight.bold),
      //       ),
      //       backgroundColor: Colors.white,
      //     ),
      //   ),
      // ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ElevatedButton(
            //   onPressed: _handleGoogleSignIn,
            //   child: const Text('Log in with Google'),
            // ),
            Text(
              '서비스 사용을 위해',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '로그인이 필요해요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleKakaoSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // 버튼 배경색
                foregroundColor: Colors.black, // 버튼 텍스트 색상
              ),
              child: const Text('카카오로 로그인하기'),
            ),
          ],
        ),
      ),
    );
  }
}

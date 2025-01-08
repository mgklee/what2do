import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginScreen extends StatelessWidget {
  final String baseUrl;
  final VoidCallback onLoginSuccess;
  final Function(Map<String, dynamic>) onBackendResponse;

  const LoginScreen({
    required this.baseUrl,
    required this.onLoginSuccess,
    required this.onBackendResponse,
    super.key,
  });

  Future<void> _handleKakaoSignIn() async {
    try {
      if (await isKakaoTalkInstalled()) {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          await _sendTokenToBackend(token.accessToken);
          onLoginSuccess();
        } catch (error) {
          print('Error during KakaoTalk Login: $error');
        }
      } else {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          await _sendTokenToBackend(token.accessToken);
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
    final url = Uri.parse("$baseUrl/users/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"oauth_token": accessToken}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      onBackendResponse(responseData);
    } else {
      print("Login failed: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '서비스 사용을 위해',
                  style: TextStyle(fontSize: 20, color: Colors.black54),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '로그인이 필요해요',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 40.0),
                // 학번 입력 필드
                TextField(
                  decoration: InputDecoration(
                    labelText: '카카오ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // 비밀번호 입력 필드
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // 비밀번호 찾기 기능 추가
                    },
                    child: const Text(
                      '비밀번호 찾기',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '소셜 로그인',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _handleKakaoSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.chat_bubble, color: Colors.black),
                      SizedBox(width: 8.0),
                      Text(
                        '카카오로 로그인하기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

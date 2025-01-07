import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Tab2 extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const Tab2({required this.userInfo, Key? key}) : super(key: key);

  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  final TextEditingController _urlController = TextEditingController(); // URL 입력 컨트롤러

  // URL 제출 함수
  void _submitUrl(String url) {
    if (url.isNotEmpty) {
      // URL 처리 로직 (예: 서버 요청)
      print('Entered URL: $url');
      _sendUrlToServer(url); // 서버에 URL 전송
    } else {
      // URL이 비어 있을 때 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("URL을 입력해주세요!")),
      );
    }
  }

  // 서버에 URL을 전송하는 함수
  Future<void> _sendUrlToServer(String url) async {
    try {
      final response = await http.post(
        Uri.parse('http://your-server-address/endpoint'), // 서버 엔드포인트 설정
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("URL이 성공적으로 제출되었습니다!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버에서 오류가 발생했습니다.")),
        );
      }
    } catch (e) {
      print('Error submitting URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류가 발생했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // URL 입력 필드
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: '에브리타임의 URL 을 입력해주세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // 키보드에서 Enter/확인 버튼을 누르면 URL 제출
                onSubmitted: (value) => _submitUrl(value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

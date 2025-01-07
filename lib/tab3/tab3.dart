import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Tab3 extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const Tab3({required this.userInfo, Key? key}) : super(key: key);

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {

  int currentPageOffset = 2;

  List<Map<String, dynamic>> friendsTodos = []; // 친구들의 todos 리스트
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    fetchFriendsTodos(); // 친구들의 todos 가져오기
  }

  // FastAPI에서 친구들의 todos 가져오기
  Future<void> fetchFriendsTodos() async {
    final userId = widget.userInfo["id"].toString(); // 사용자 ID 가져오기
    final nickname = widget.userInfo["nickname"]; // 닉네임 가져오기
    final profileImage = widget.userInfo["profile_image"]; // 프로필 이미지

    if (userId == null) {
      print('Error: user_id is null');
      return; // user_id가 null이면 요청을 보내지 않음
    }

    try {
      final url = Uri.parse('http://172.10.7.56:8000/users/$userId/friends/todos');
      final response = await http.get(url);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${utf8.decode(response.bodyBytes)}'); // UTF-8 디코딩된 응답 본문 출력

      if (response.statusCode == 200) {
        setState(() {
          friendsTodos = List<Map<String, dynamic>>.from(
              json.decode(utf8.decode(response.bodyBytes)) // UTF-8 디코딩 후 JSON 디코딩
          );
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load todos');
      }
    } catch (e) {
      print('Error fetching todos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중
          : ListView.builder(
        itemCount: friendsTodos.length,
        itemBuilder: (context, index) {
          final friendTodos = friendsTodos[index];
          final nickname = friendTodos['nickname'];
          final profileImage = friendTodos['profile_image'];
          final categories = List<Map<String, dynamic>>.from(friendTodos['categories']);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 친구의 닉네임과 프로필 이미지
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: profileImage != null
                          ? NetworkImage(profileImage)
                          : null,
                      child: profileImage == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      nickname ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 카테고리별 카드 가로 스크롤
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, categoryIndex) {
                      final category = categories[categoryIndex];
                      final todos = List<Map<String, dynamic>>.from(category['todos']);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        padding: const EdgeInsets.all(8.0),
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 카테고리 제목
                            Text(
                              category['category'] ?? "Unknown",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 카테고리 내 할 일
                            Expanded(
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: todos.length,
                                itemBuilder: (context, todoIndex) {
                                  final todo = todos[todoIndex];
                                  return Row(
                                    children: [
                                      const Icon(Icons.check_box_outline_blank, size: 16),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          todo['task'] ?? "No Task",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

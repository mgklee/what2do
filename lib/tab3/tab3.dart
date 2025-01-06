import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Tab3 extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const Tab3({required this.userInfo, super.key});

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
  List<Map<String, dynamic>> friendsTodos = []; // 친구들의 할 일 목록
  bool isLoading = true; // 로딩 상태
  bool hasError = false; // 에러 상태

  @override
  void initState() {
    super.initState();
    fetchFriendsTodos(); // 초기 데이터 로딩
  }

  // 친구들의 TODO 목록 불러오기
  Future<void> fetchFriendsTodos() async {
    final userId = widget.userInfo['id']; // userInfo에서 user_id 가져오기
    final url = Uri.parse("http://172.10.7.56:8000/users/$userId/friends/todos");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          friendsTodos = List<Map<String, dynamic>>.from(responseData['data'] ?? []);
          isLoading = false;
          hasError = false;
        });
      } else {
        handleFetchError();
        print("Failed to fetch todos: ${response.body}");
      }
    } catch (e) {
      handleFetchError();
      print("Error fetching todos: $e");
    }
  }

  void handleFetchError() {
    setState(() {
      hasError = true;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends' TODOs"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 표시
          : hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Failed to load friends' TODOs",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchFriendsTodos, // 다시 시도 버튼
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : friendsTodos.isEmpty
          ? const Center(
        child: Text(
          "No TODOs found for your friends.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: friendsTodos.length,
        itemBuilder: (context, index) {
          final friend = friendsTodos[index];
          return FriendTodoCard(friend: friend);
        },
      ),
    );
  }
}

class FriendTodoCard extends StatelessWidget {
  final Map<String, dynamic> friend;

  const FriendTodoCard({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 친구 정보 (이름 및 아바타)
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(friend['profile_image'] ?? "https://via.placeholder.com/150"),
                radius: 30,
              ),
              const SizedBox(width: 10),
              Text(
                friend['nickname'] ?? "Unknown",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 할 일 목록 (가로 스크롤)
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (friend['todos'] ?? []).length,
              itemBuilder: (context, index) {
                final todo = friend['todos'][index];
                return TodoCategoryCard(category: todo['category'], tasks: todo['tasks']);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TodoCategoryCard extends StatelessWidget {
  final String category;
  final List<String> tasks;

  const TodoCategoryCard({Key? key, required this.category, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        const Icon(Icons.check_box_outline_blank, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          tasks[index],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

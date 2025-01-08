import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Tab3 extends StatefulWidget {
  final String baseUrl;
  final Map<String, dynamic> userInfo;

  const Tab3({
    required this.baseUrl,
    required this.userInfo,
    super.key
  });

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
  final List<String> weekDays = ['일', '월', '화', '수', '목', '금', '토']; // Fixed week days
  late final int initialPage; // Set today as the initial page
  DateTime? selectedDay; // Tracks the currently selected day
  int currentPageOffset = 0; // Tracks the current week offset
  List<Map<String, dynamic>> friendsTodos = []; // 친구들의 todos 리스트

  @override
  void initState() {
    super.initState();
    initialPage = DateTime.now().difference(_getReferenceSunday()).inDays ~/ 7;
    selectedDay = DateTime.now(); // Default to today
    _fetchFriendsTodos(); // 친구들의 todos 가져오기
  }

  // FastAPI에서 친구들의 todos 가져오기
  Future<void> _fetchFriendsTodos() async {
    // selectedDay가 null이면 오늘 날짜를 기본값으로 설정
    final selectedDate = selectedDay ?? DateTime.now();

    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/users/${widget.userInfo['id']}/friends/todos?date=${DateFormat('yyyy-MM-dd').format(selectedDate)}')
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${jsonDecode(utf8.decode(response.bodyBytes))}'); // UTF-8 디코딩된 응답 본문 출력

      if (response.statusCode == 200) {
        setState(() {
          friendsTodos = List<Map<String, dynamic>>.from(
            jsonDecode(utf8.decode(response.bodyBytes)) // UTF-8 디코딩 후 JSON 디코딩
          );
        });
      } else {
        throw Exception('Failed to load todos');
      }
    } catch (error) {
      print('Error fetching todos: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Fixed Weekly Calendar
          _buildWeeklyCalendar(context),

          ...friendsTodos.map((element) {
            final friendTodos = element;
            final nickname = friendTodos['nickname'];
            final profileImage = friendTodos['profile_image'];
            final categories = List<Map<String, dynamic>>.from(friendTodos['categories']);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 20),
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
                          padding: const EdgeInsets.all(8.0),
                          width: 200,
                          decoration: BoxDecoration(
                            color: Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade400,
                                offset: Offset(2, 2),
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
                                        todo['isCompleted']
                                        ? const Icon(Icons.check_box, size: 16)
                                        : const Icon(Icons.check_box_outline_blank, size: 16),
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
          })
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar(BuildContext context) {
    return Column(
      children: [
        // Display the week number
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _getWeekNumber(DateTime.now().add(Duration(days: currentPageOffset * 7))),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Fixed Weekdays Row with aligned Dates
        SizedBox(
          height: 120,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: weekDays.asMap().entries.map((entry) {
                    int index = entry.key;
                    String day = entry.value;
                    return Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: index == 0
                            ? Colors.red // Sunday is red
                            : index == 6
                            ? Colors.blue // Saturday is blue
                            : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PageView.builder(
                  controller: PageController(initialPage: initialPage),
                  onPageChanged: (index) {
                    setState(() {
                      currentPageOffset = index - initialPage; // Update the offset for the displayed week
                    });
                  },
                  itemBuilder: (context, pageOffset) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          DateTime day = _calculateDateForPage(pageOffset, index);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDay = day; // Update the selected day
                                });
                                _fetchFriendsTodos(); // Fetch data for the selected day
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (_isSelected(day))
                                          const CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Color(0xFF18C971),
                                          )
                                        else if (_isToday(day))
                                          const CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Color(0x8018C971),
                                          ),
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: _isSelected(day)
                                            ? Colors.white
                                            : (index == 0
                                            ? Colors.red
                                            : index == 6
                                            ? Colors.blue
                                            : Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  DateTime _getReferenceSunday() => DateTime(2000, 1, 2);

  DateTime _calculateDateForPage(int pageOffset, int dayIndex) {
    DateTime baseSunday = _getReferenceSunday();
    return baseSunday.add(Duration(days: pageOffset * 7 + dayIndex));
  }

  String _getWeekNumber(DateTime date) {
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int daysSinceStartOfMonth = date.difference(firstDayOfMonth).inDays;
    int weekOfMonth = (daysSinceStartOfMonth ~/ 7) + 1;

    return "${date.year}년 ${date.month}월 $weekOfMonth주차";
  }

  bool _isSelected(DateTime date) {
    return selectedDay?.day == date.day &&
        selectedDay?.month == date.month &&
        selectedDay?.year == date.year;
  }

  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

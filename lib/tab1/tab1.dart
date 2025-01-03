import 'package:flutter/material.dart';

class Tab1 extends StatefulWidget {
  const Tab1({super.key});

  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  final List<String> weekDays = ['일', '월', '화', '수', '목', '금', '토']; // Fixed week days
  late final int initialPage; // Set today as the initial page
  DateTime? selectedDay; // Tracks the currently selected day
  int currentPageOffset = 0; // Tracks the current week offset

  // Sample task data
  final Map<String, List<Map<String, dynamic>>> taskData = {
    '공부': [
      {'task': '선대 과제 수행', 'completed': false},
      {'task': 'node.js 공부', 'completed': false},
      {'task': '레포트 작성', 'completed': false},
    ],
    '놀기': [
      {'task': '민지랑 3시 약구정', 'completed': false},
      {'task': '선영이랑 약속 잡기', 'completed': false},
    ],
    '취미': [
      {'task': '반지 만들기', 'completed': false},
      {'task': '검정치마 티켓팅 7시', 'completed': false},
      {'task': '기타 연습 1시간', 'completed': false},
    ],
  };

  @override
  void initState() {
    super.initState();
    // Calculate the starting page as the number of weeks since a fixed reference Sunday
    initialPage = DateTime.now().difference(_getReferenceSunday()).inDays ~/ 7;
    selectedDay = DateTime.now(); // Default to today
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Week Number and Calendar Section
            _buildWeekNumberAndCalendar(),
            const SizedBox(height: 16),

            // Task Sections
            ...taskData.keys.map((category) => _buildTaskCategory(category, taskData[category]!)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekNumberAndCalendar() {
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
          height: 160, // Adjusted height for larger text
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
                            fontSize: 20, // Increased font size for weekdays
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
              const SizedBox(height: 20), // Adjusted spacing for alignment
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
                        children: List.generate(
                          7,
                              (index) {
                            DateTime day = _calculateDateForPage(pageOffset, index);
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDay = day; // Update the selected day
                                  });
                                },
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 40, // Adjusted size for date area
                                      width: 40,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (_isSelected(day))
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.green,
                                            ),
                                          Text(
                                            day.day.toString(),
                                            style: TextStyle(
                                              fontSize: 18, // Increased font size for dates
                                              color: _isSelected(day)
                                                  ? Colors.white
                                                  : (index == 0
                                                  ? Colors.red // Sunday date is red
                                                  : index == 6
                                                  ? Colors.blue // Saturday date is blue
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
                          },
                        ),
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

  Widget _buildTaskCategory(String title, List<Map<String, dynamic>> tasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock, size: 16),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ...tasks.map((task) {
              return Row(
                children: [
                  Checkbox(
                    value: task['completed'],
                    onChanged: (value) {
                      setState(() {
                        task['completed'] = value;
                      });
                    },
                  ),
                  Text(task['task']),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Helper to calculate the reference Sunday (January 2, 2000)
  DateTime _getReferenceSunday() {
    return DateTime(2000, 1, 2);
  }

  // Helper to calculate the date for each day in the current week
  DateTime _calculateDateForPage(int pageOffset, int dayIndex) {
    DateTime baseSunday = _getReferenceSunday();
    return baseSunday.add(Duration(days: pageOffset * 7 + dayIndex));
  }

  // Helper to calculate the week number
  String _getWeekNumber(DateTime date) {
    // Get the first day of the month
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);

    // Calculate the number of days since the start of the month
    int daysSinceStartOfMonth = date.difference(firstDayOfMonth).inDays;

    // Calculate the week number (1-based index)
    int weekOfMonth = (daysSinceStartOfMonth ~/ 7) + 1;

    return "${date.year}년 ${date.month}월 ${weekOfMonth}주차";
  }

  // Helper to check if a given date is selected
  bool _isSelected(DateTime date) {
    return selectedDay?.day == date.day &&
        selectedDay?.month == date.month &&
        selectedDay?.year == date.year;
  }
}

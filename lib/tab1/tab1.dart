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
  Map<DateTime, Map<String, List<Map<String, dynamic>>>> toDoList = {};
  final TextEditingController toDoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Calculate the starting page as the number of weeks since a fixed reference Sunday
    initialPage = DateTime.now().difference(_getReferenceSunday()).inDays ~/ 7;
    selectedDay = DateTime.now(); // Default to today
  }

  @override
  void dispose() {
    toDoController.dispose();
    super.dispose();
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
            _buildToDoList(),
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
          height: 120, // Adjusted height for larger text
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
                                              backgroundColor: Color(0xFF18C971),
                                            )
                                          else if (_isToday(day))
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Color(0x8018C971),
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

  Widget _buildToDoList() {
    if (selectedDay == null) return const SizedBox();

    DateTime key = DateTime(
        selectedDay!.year, selectedDay!.month, selectedDay!.day);
    toDoList[key] ??= {}; // Initialize categories for the day if not present
    Map<String, List<Map<String, dynamic>>> categories = toDoList[key]!;
    String selectedCategory = categories.keys.isNotEmpty
        ? categories.keys.first
        : "Default";

    return StatefulBuilder(
      builder: (context, setState) {
        List<Map<String, dynamic>> tasks = categories[selectedCategory] ?? [];

        return Column(
          children: [
            // Display all categories as a scrollable row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: categories.keys.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCategory == category
                            ? Colors.green
                            : Colors.grey, // Highlight selected category
                      ),
                      onPressed: () {
                        setState(() {
                          selectedCategory =
                              category; // Switch to the selected category
                        });
                      },
                      child: Text(category),
                    ),
                  );
                }).toList()
                  ..add(
                    // Add button to create a new category
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        onPressed: () {
                          _showAddCategoryDialog(context, setState, categories);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("New Category"),
                      ),
                    ),
                  ),
              ),
            ),

            // Display tasks for the selected category
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: tasks[index]['isCompleted'],
                    onChanged: (value) {
                      setState(() {
                        tasks[index]['isCompleted'] = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  title: tasks[index]['isEditing']
                      ? TextField(
                    autofocus: true,
                    controller: TextEditingController(
                      text: tasks[index]['text'],
                    ),
                    onSubmitted: (newValue) {
                      setState(() {
                        tasks[index]['text'] = newValue;
                        tasks[index]['isEditing'] = false;
                      });
                    },
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  )
                      : GestureDetector(
                    onTap: () => _showTaskMenu(context, tasks, index),
                    child: Text(
                      tasks[index]['text'],
                      style: TextStyle(
                        decoration: tasks[index]['isCompleted']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Add new task input field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: toDoController,
                onSubmitted: (newValue) {
                  if (newValue.isNotEmpty) {
                    setState(() {
                      categories[selectedCategory] ??= [];
                      categories[selectedCategory]?.add({
                        'text': newValue,
                        'isCompleted': false,
                        'isEditing': false,
                      });
                      toDoController.clear();
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: "New Task",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, void Function(void Function()) setState,
      Map<String, List<Map<String, dynamic>>> categories) {
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Category"),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: "Category Name",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green, width: 2.0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final newCategory = categoryController.text.trim();
                if (newCategory.isNotEmpty && !categories.containsKey(newCategory)) {
                  setState(() {
                    categories[newCategory] = [];
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Helper to calculate the reference Sunday (January 2, 2000)
  DateTime _getReferenceSunday() => DateTime(2000, 1, 2);

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

    return "${date.year}년 ${date.month}월 $weekOfMonth주차";
  }

  // Helper to check if a given date is selected
  bool _isSelected(DateTime date) {
    return selectedDay?.day == date.day &&
        selectedDay?.month == date.month &&
        selectedDay?.year == date.year;
  }

  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _showTaskMenu(BuildContext context, List<Map<String, dynamic>> tasks, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _modifyTask(tasks, index); // Enter inline editing mode
                },
                icon: const Icon(Icons.edit),
                label: const Text('Modify'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Modify button color
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    tasks.removeAt(index); // Delete the task
                    if (tasks.isEmpty) {
                      DateTime key = DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day);
                      toDoList.remove(key);
                    }
                  });
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Delete button color
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _modifyTask(List<Map<String, dynamic>> tasks, int index) {
    setState(() {
      tasks[index]['isEditing'] = true; // Enable inline editing for the selected task
    });
  }
}

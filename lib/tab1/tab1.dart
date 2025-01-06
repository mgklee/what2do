import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Tab1 extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const Tab1({required this.userInfo, super.key});

  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  final String baseUrl = 'http://172.10.7.56:8000';
  final List<String> weekDays = ['일', '월', '화', '수', '목', '금', '토']; // Fixed week days
  late final int initialPage; // Set today as the initial page
  DateTime? selectedDay; // Tracks the currently selected day
  int currentPageOffset = 0; // Tracks the current week offset
  Map<DateTime, Map<String, Map<String, dynamic>>> toDoList = {};

  @override
  void initState() {
    super.initState();
    // Calculate the starting page as the number of weeks since a fixed reference Sunday
    initialPage = DateTime.now().difference(_getReferenceSunday()).inDays ~/ 7;
    selectedDay = DateTime.now(); // Default to today
    _fetchToDoList();
  }

  Future<void> _fetchToDoList() async {
    if (selectedDay == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todolist?date=${selectedDay!.toIso8601String()}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          toDoList[selectedDay!] = Map<String, Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to fetch to-do list: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching to-do list: $error');
    }
  }

  Future<void> _updateToDoList() async {
    if (selectedDay == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todolist'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': selectedDay!.toIso8601String(),
          'toDoList': toDoList[selectedDay!],
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to update to-do list: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating to-do list: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Fixed Weekly Calendar
            _buildWeeklyCalendar(),

            // Scrollable To-Do List
            Expanded(
              child: SingleChildScrollView(
                child: _buildToDoList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
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

  Widget _buildToDoList() {
    if (selectedDay == null) return const SizedBox();

    DateTime key = DateTime(selectedDay!.year, selectedDay!.month, selectedDay!.day);
    toDoList[key] ??= {}; // Initialize categories for the day if not present
    Map<String, Map<String, dynamic>> categories = toDoList[key]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.keys.length + 1, // Extra card for the (+) button
          itemBuilder: (context, index) {
            // (+) Button Card
            if (index == categories.keys.length) {
              return Card(
                color: Colors.grey[200],
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      // Add a new empty category with a unique name
                      setState(() {
                        int categoryIndex = 1;
                        String newCategoryName;
                        do {
                          newCategoryName = "카테고리 $categoryIndex";
                          categoryIndex++;
                        } while (categories.containsKey(newCategoryName));

                        categories[newCategoryName] = {
                          'isEditing': true,
                          'isPublic': true,
                          'tasks': <Map<String, dynamic>>[], // Ensure the correct type
                        };
                      });
                      _updateToDoList();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.add, size: 40.0, color: Color(0xFF18C971)),
                    ),
                  ),
                ),
              );
            }

            // Existing Category Cards
            String categoryName = categories.keys.elementAt(index);
            String newName = categoryName;
            bool isEditing = categories[categoryName]?['isEditing'] ?? false;
            bool isPublic = categories[categoryName]?['isPublic'] ?? true;
            List<Map<String, dynamic>> tasks = categories[categoryName]?['tasks'] ?? [];

            return Card(
              color: Colors.grey[200],
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                children: [
                  // Category Title with Add (+) Button
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Public/Private Icon
                        IconButton(
                          onPressed: () {
                            setState(() {
                              categories[categoryName]?['isPublic'] = !(categories[categoryName]?['isPublic'] ?? true);
                            });
                            _updateToDoList();
                          },
                          icon: Icon(
                            isPublic ? Icons.public : Icons.lock,
                          ),
                        ),
                        // Category Name or Edit Field
                        isEditing
                          ? Expanded(
                            child: Focus( // Added Focus widget to detect unfocus
                              onFocusChange: (hasFocus) {
                                if (!hasFocus) {
                                  setState(() {
                                    if (newName.isNotEmpty && !categories.containsKey(newName)) {
                                      categories[newName] = {
                                        'isEditing': false,
                                        'isPublic': categories[categoryName]?['isPublic'] ?? true,
                                        'tasks': categories[categoryName]?['tasks'] ?? [],
                                      };
                                      categories.remove(categoryName);
                                    } else {
                                      categories[categoryName]?['isEditing'] = false;
                                    }
                                  });
                                  _updateToDoList();
                                }
                              },
                              child: TextField(
                                autofocus: true,
                                controller: TextEditingController(text: categoryName),
                                onSubmitted: (text) {
                                  newName = text;
                                  setState(() {
                                    if (newName.isNotEmpty && !categories.containsKey(newName)) {
                                      categories[newName] = {
                                        'isEditing': false,
                                        'isPublic': categories[categoryName]?['isPublic'] ?? true,
                                        'tasks': categories[categoryName]?['tasks'] ?? [],
                                      };
                                      categories.remove(categoryName);
                                    } else {
                                      categories[categoryName]?['isEditing'] = false;
                                    }
                                  });
                                  _updateToDoList();
                                },
                                onChanged: (text) {
                                  newName = text;
                                },
                                decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF18C971), width: 2.0),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          )
                          : Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _showCategoryMenu(context, categories, categoryName, setState);
                              },
                              child: Text(
                                categoryName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        // Add (+) Button
                        IconButton(
                          onPressed: () {
                            setState(() {
                              tasks.add({
                                'text': "New Task ${tasks.length + 1}",
                                'isCompleted': false,
                                'isEditing': true,
                              });
                            });
                            _updateToDoList();
                          },
                          icon: const Icon(Icons.add),
                          tooltip: 'Add Task',
                        ),
                      ],
                    ),
                  ),

                  // Tasks for the Category
                  ...tasks.map((task) {
                    String newValue = task['text'];
                    return ListTile(
                      visualDensity: VisualDensity.compact,
                      leading: Checkbox(
                        value: task['isCompleted'],
                        onChanged: (value) {
                          setState(() {
                            task['isCompleted'] = value!;
                          });
                          _updateToDoList();
                        },
                        activeColor: Color(0xFF18C971),
                      ),
                      title: task['isEditing']
                        ? Focus( // Added Focus widget to detect unfocus
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            setState(() {
                              task['text'] = newValue;
                              task['isEditing'] = false;
                            });
                            _updateToDoList();
                          }
                        },
                        child: TextField(
                          autofocus: true,
                          controller: TextEditingController(text: task['text']),
                          onSubmitted: (newValue) {
                            setState(() {
                              task['text'] = newValue;
                              task['isEditing'] = false;
                            });
                            _updateToDoList();
                          },
                          onChanged: (text) {
                            newValue = text;
                          },
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF18C971), width: 2.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      )
                      : GestureDetector(
                        onTap: () => _showTaskMenu(context, tasks, tasks.indexOf(task)),
                        child: Text(
                          task['text'],
                          style: TextStyle(
                            color: task['isCompleted']
                              ? Colors.grey
                              : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
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

  void _showCategoryMenu(BuildContext context, Map<String, Map<String, dynamic>> categories,
      String categoryName, void Function(void Function()) setState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _modifyCategory(categories, categoryName, setState);
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  label: const Text(
                    '수정하기',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      categories.remove(categoryName);
                    });
                    _updateToDoList();
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  label: const Text(
                    '삭제하기',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _modifyCategory(Map<String, Map<String, dynamic>> categories, String categoryName,
      void Function(void Function()) setState) {
    setState(() {
      categories[categoryName]?['isEditing'] = true;
    });
  }

  void _showTaskMenu(BuildContext context, List<Map<String, dynamic>> tasks, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _modifyTask(tasks, index);
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  label: const Text(
                    '수정하기',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      tasks.removeAt(index);
                    });
                    _updateToDoList();
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  label: const Text(
                    '삭제하기',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
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
      tasks[index]['isEditing'] = true;
    });
  }
}

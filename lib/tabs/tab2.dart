import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Tab2 extends StatefulWidget {
  final String baseUrl;
  final Map<String, dynamic> userInfo;

  const Tab2({
    required this.baseUrl,
    required this.userInfo,
    super.key
  });

  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  final TextEditingController _urlController = TextEditingController(); // URL 입력 컨트롤러
  List<List<int>> binaryList = [];
  List<Map<String, dynamic>> friends = []; // 친구 목록
  List<int> ids = [];
  int year = 2024;
  int season = 2;
  String semester = '2024년 2학기';

  @override
  void initState() {
    super.initState();
    ids.add(widget.userInfo['id']);
    _fetchBinaryList();
    _loadFriends();
  }

  // URL 제출 함수
  void _submitUrl(String url) async {
    final uri = Uri.parse('${widget.baseUrl}/users/${widget.userInfo['id']}/timetable');
    final body = jsonEncode({
      'year': year,
      'season': season,
      'url': url,
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        print("POST successful. Fetching timetable...");
        await _fetchBinaryList(); // GET 요청 호출
      } else {
        print('Failed to save timetable: ${response.body}');
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('시간표 저장에 실패했습니다.'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('서버와 통신 중 오류가 발생했습니다.'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _fetchBinaryList() async {
    String queryString = ids.map((id) => "ids=$id").join("&");
    final uri = Uri.parse('${widget.baseUrl}/users/${widget.userInfo['id']}/timetable/$year/$season?$queryString');

    setState(() {
      binaryList = [];
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          binaryList = List<List<int>>.from(
            responseData['array'].map((row) => List<int>.from(row)),
          );
          for(int i = 0; i < 56; i++) {
              print(binaryList[i]);
            }
        });
      } else {
        print('Failed to fetch timetable: ${response.body}');
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('시간표 조회에 실패했습니다.'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('서버와 통신 중 오류가 발생했습니다.'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _loadFriends() async {
    try {
      final fetchedFriends = await fetchFriends(widget.userInfo['id']);
      setState(() {
        friends = fetchedFriends.map((friend) {
          return {
            ...friend,
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading friends: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 목록을 불러오는 데 실패했습니다.')),
      );
    }
  }

  // 친구 목록 API 호출 함수
  Future<List<Map<String, dynamic>>> fetchFriends(int userId) async {
    final url = Uri.parse('${widget.baseUrl}/users/$userId/friends');
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(responseData['friends']);
      } else if (response.statusCode == 404) {
        print("No friends found.");
        return [];
      } else {
        print("Failed to fetch friends: ${response.body}");
        throw Exception("Failed to fetch friends");
      }
    } catch (e) {
      print("Error fetching friends: $e");
      throw Exception("Error fetching friends");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> semesters = [];
    List<int> years = [2024, 2023, 2022, 2021, 2020];
    List<String> seasons = ["겨울학기", "2학기", "여름학기", "1학기"];

    for (int year in years) {
      for (String season in seasons) {
        semesters.add("$year년 $season");
      }
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              DropdownButton<String>(
                value: semester,
                onChanged: (String? newValue) {
                  setState(() {
                    semester = newValue!;
                    final parts = newValue.split('년 ');
                    year = int.parse(parts[0]);
                    season = 3 - seasons.indexOf(parts[1]);
                    _fetchBinaryList();
                  });
                },
                items: semesters.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              binaryList.isEmpty
              ? Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7), // 배경색 설정
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: '에브리타임 시간표 URL을 입력해 주세요.',
                      border: InputBorder.none, // 테두리 제거
                    ),
                    onSubmitted: (value) => _submitUrl(value),
                  ),
                ),
              )
              : Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double cellHeight = constraints.maxHeight / (binaryList.length + 1);
                    double cellWidth = constraints.maxWidth / 8;
                    double headerHeight = cellHeight * 2;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: cellWidth,
                              height: headerHeight,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Center(child: Text('')),
                            ),
                            for (String day in ['월', '화', '수', '목', '금', '토', '일'])
                              Container(
                                width: cellWidth,
                                height: headerHeight,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.grey[300]!, width: 1),
                                    right: BorderSide(color: Colors.grey[300]!, width: 1),
                                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                                  ),
                                ),
                                child: Center(child: Text(day, style: TextStyle(fontWeight: FontWeight.bold))),
                              ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: binaryList.length ~/ 4,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: cellWidth,
                                        height: cellHeight * 4,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(color: Colors.grey[300]!, width: 1),
                                            right: BorderSide(color: Colors.grey[300]!, width: 1),
                                            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 2.0),
                                            child: Text(
                                              '${8 + index}',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: List.generate(4, (rowOffset) {
                                          int rowIndex = index * 4 + rowOffset;
                                          return Row(
                                            children: [
                                              for (int colIndex = 0; colIndex < 7; colIndex++)
                                                Container(
                                                  width: cellWidth,
                                                  height: cellHeight,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(24, 201, 113, min(0.2*binaryList[rowIndex][colIndex], 1)),
                                                    border: Border(
                                                      right: BorderSide(color: Colors.grey[300]!, width: 1.0),
                                                      bottom: rowOffset == 3
                                                      ? BorderSide(color: Colors.grey[300]!, width: 1.0)
                                                      : BorderSide.none,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        }),
                                      )
                                    ],
                                  ),
                                  Divider(height: 0, thickness: 1, color: Colors.grey[300]!),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // DraggableScrollableSheet for Friends List
        DraggableScrollableSheet(
          initialChildSize: 0.1, // 초기 높이 (화면의 20%)
          minChildSize: 0.1, // 최소 높이
          maxChildSize: 0.8, // 최대 높이 (화면의 80%)
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 위젯 상단의 드래그 핸들
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 친구 목록
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return ListTile(
                          leading: Switch(
                            value: ids.contains(friend['id']),
                            onChanged: (bool value) {
                              setState(() {
                                if (value) {
                                  ids.add(friend['id']);
                                } else {
                                  ids.remove(friend['id']);
                                }
                                print(ids);
                                _fetchBinaryList();
                              });
                            },
                          ),
                          title: Text(friend['nickname'] ?? "Unknown"),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

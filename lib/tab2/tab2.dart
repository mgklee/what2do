import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Tab2 extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const Tab2({required this.userInfo, super.key});

  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  final TextEditingController _urlController = TextEditingController(); // URL 입력 컨트롤러
  final String baseUrl = 'http://172.10.7.56:8000';
  List<List<int>> binaryList = [];
  // List<List<int>> binaryList = [
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 1, 0, 1, 0, 0, 0],
  //   [0, 1, 0, 1, 0, 0, 0],
  //   [0, 1, 0, 1, 0, 0, 0],
  //   [0, 1, 0, 1, 0, 0, 0],
  //   [0, 1, 0, 1, 0, 0, 0],
  //   [0, 1, 0, 1, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [1, 0, 1, 0, 0, 0, 0],
  //   [0, 1, 0, 1, 1, 0, 0],
  //   [0, 1, 0, 1, 1, 0, 0],
  //   [0, 1, 0, 1, 1, 0, 0],
  //   [0, 1, 0, 1, 1, 0, 0],
  //   [0, 1, 0, 1, 1, 0, 0],
  //   [0, 1, 0, 1, 1, 0, 0],
  //   [0, 1, 1, 1, 0, 0, 0],
  //   [0, 1, 1, 1, 0, 0, 0],
  //   [0, 1, 1, 1, 0, 0, 0],
  //   [0, 1, 1, 1, 0, 0, 0],
  //   [0, 1, 1, 1, 0, 0, 0],
  //   [0, 1, 1, 1, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0],
  // ];
  late int year;
  late int season;
  String semester = '2024 가을학기';

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
        Uri.parse('$baseUrl/users/${widget.userInfo['id']}/timetable/$year/$season'),
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

  Future<void> _fetchBinaryList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/${widget.userInfo['id']}/timetable/$year/$season'),
      );

      setState(() {
        binaryList = [];
      });

      if (response.statusCode == 200) {
        setState(() {
          binaryList = List<List<int>>.from(
            json.decode(response.body).map((row) => List<int>.from(row)),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch data from the server. ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error while fetching data.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> semesters = [];
    List<int> years = [2024, 2023, 2022, 2021, 2020];
    List<String> seasons = ["겨울학기", "가을학기", "여름학기", "봄학기"];

    for (int year in years) {
      for (String season in seasons) {
        semesters.add("$year $season");
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
                    final parts = newValue.split(' ');
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
                ? TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: '에브리타임 시간표 URL을 입력해 주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // 키보드에서 Enter/확인 버튼을 누르면 URL 제출
                  onSubmitted: (value) => _submitUrl(value),
                )
                : LayoutBuilder(
                  builder: (context, constraints) {
                    double cellHeight = constraints.maxHeight / (binaryList.length + 1);
                    double cellWidth = constraints.maxWidth / 8;
                    double headerHeight = cellHeight * 2;

                    return Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: cellWidth,
                                height: headerHeight,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Center(child: Text('')),
                              ),
                              for (String day in ['월', '화', '수', '목', '금', '토', '일'])
                                Container(
                                  width: cellWidth,
                                  height: headerHeight,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Colors.grey, width: 1),
                                      right: BorderSide(color: Colors.grey, width: 1),
                                      bottom: BorderSide(color: Colors.grey, width: 1),
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
                                              left: BorderSide(color: Colors.grey, width: 1),
                                              right: BorderSide(color: Colors.grey, width: 1),
                                              bottom: BorderSide(color: Colors.grey, width: 1),
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
                                                      color: binaryList[rowIndex][colIndex] == 1
                                                          ? Color(0xFF18C971)
                                                          : Colors.white,
                                                      border: Border(
                                                        right: BorderSide(color: Colors.grey, width: 1.0),
                                                        bottom: rowOffset == 3
                                                            ? BorderSide(color: Colors.grey, width: 1.0)
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
                                    Divider(height: 0, thickness: 1, color: Colors.grey),
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
            ],
          ),
        ),
        // DraggableScrollableSheet(
        //   initialChildSize: 0.1, // Start with 10% of screen height
        //   minChildSize: 0.1, // Minimum size
        //   maxChildSize: 0.8, // Maximum size
        //   builder: (context, scrollController) {
        //     return Container(
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.black26,
        //             blurRadius: 10,
        //             spreadRadius: 2,
        //           ),
        //         ],
        //       ),
        //       child: Column(
        //         children: [
        //           // A small handle to indicate the draggable area
        //           Container(
        //             margin: EdgeInsets.only(top: 8),
        //             width: 40,
        //             height: 5,
        //             decoration: BoxDecoration(
        //               color: Colors.grey[400],
        //               borderRadius: BorderRadius.circular(10),
        //             ),
        //           ),
        //           Expanded(
        //             child: ListView.builder(
        //               controller: scrollController,
        //               itemCount: friends.length,
        //               itemBuilder: (context, index) {
        //                 return ListTile(
        //                   leading: CircleAvatar(
        //                     child: Text(friends[index][0]),
        //                   ),
        //                   title: Text(friends[index]),
        //                 );
        //               },
        //             ),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}

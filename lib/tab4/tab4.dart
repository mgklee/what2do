import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

class Tab4 extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final VoidCallback onLogout; // Callback for logout

  const Tab4({
    required this.userInfo,
    required this.onLogout,
    super.key
  });

  @override
  _Tab4State createState() => _Tab4State();
}

Future<List<Map<String, dynamic>>> fetchFriends(String userId) async {
  final url = Uri.parse("http://172.10.7.56:8000/users/$userId/friends");

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

class QRCodeScanner extends StatefulWidget {
  final String userId; // 현재 사용자 ID

  const QRCodeScanner({required this.userId, Key? key}) : super(key: key);

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR 코드 스캔')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: const Text(
                'QR 코드를 스캔하여 친구를 추가하세요.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      _handleQRCode(scanData.code);
    });
  }

  Future<void> _handleQRCode(String? qrCodeData) async {
    if (qrCodeData == null) {
      print('QR 코드 데이터가 없습니다.');
      return;
    }

    try {
      // QR 코드 데이터를 JSON으로 파싱
      final qrJson = jsonDecode(qrCodeData);
      final qrUserId = qrJson['user_id'];

      // 서버로 요청 보내기
      final response = await http.post(
        Uri.parse('http://172.10.7.56:8000/friends'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "scanned_user_id": widget.userId,
          "qr_user_id": qrUserId,
        }),
      );

      if (response.statusCode == 200) {
        // 친구 추가 성공
        print('친구 추가 성공: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('친구가 성공적으로 추가되었습니다.')),
        );
        Navigator.of(context).pop(); // 스캔 화면 종료
      } else {
        // 실패 메시지 출력
        print('친구 추가 실패: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('친구 추가에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('QR 코드 처리 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR 코드 처리 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}


class _Tab4State extends State<Tab4> {
  int currentPageOffset = 3;

  @override
  Widget build(BuildContext context) {
    final userId = widget.userInfo["id"].toString(); // 사용자 ID 가져오기
    final nickname = widget.userInfo["nickname"]; // 닉네임 가져오기
    final profileImage = widget.userInfo["profile_image"]; // 프로필 이미지

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 30, // 이미지 크기
                    backgroundImage: profileImage != null
                        ? NetworkImage(profileImage) // 네트워크 이미지
                        : null, // null이면 기본 아이콘 표시
                    child: profileImage == null
                        ? const Icon(Icons.person, size: 30) // 기본 아이콘
                        : null,
                  ),
                  const SizedBox(width: 10), // 이미지와 닉네임 간격
                  // 닉네임
                  Text(
                    nickname ?? "Unknown", // 닉네임이 없으면 기본값
                    style: const TextStyle(
                      fontSize: 20, // 폰트 크기
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // 위젯 간 간격
              Card(
                elevation: 0,
                color: Colors.white,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // 친구 추가
                      ListTile(
                        title: const Text(
                          '친구 추가',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF777777),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRCodeScanner(userId: userId),
                            ),
                          );
                        },
                        trailing: const Icon(Icons.camera_alt, color: Color(0xFF777777)), // 사진 아이콘 추가
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Color(0xFFBDBDBD),
                          thickness: 1,
                        ),
                      ),
                      // 내 QR 코드
                      ListTile(
                        title: const Text(
                          '내 QR 코드',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF777777),
                          ),
                        ),
                        onTap: () {
                          showAddFriendDialog(userId); // 내 QR 코드를 보여주는 다이얼로그 호출
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Color(0xFFBDBDBD),
                          thickness: 1,
                        ),
                      ),
                      // 친구 목록
                      ListTile(
                        title: const Text(
                          '친구 목록',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF777777),
                          ),
                        ),
                        onTap: () {
                          navigateToFriendList(userId); // 인자를 전달하며 함수 호출
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Color(0xFFBDBDBD),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '  개인정보 관리',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
              Card(
                elevation: 0,
                color: Colors.white,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('내 정보 관리'),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Color(0xFFBDBDBD),
                          thickness: 1,
                        ),
                      ),
                      ListTile(
                        title: const Text('고객센터'),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Color(0xFFBDBDBD),
                          thickness: 1,
                        ),
                      ),
                      ListTile(
                        title: const Text('이용약관 동의'),
                        trailing: TextButton(
                          onPressed: () {
                            dialog1();
                          },
                          child: const Text(
                            '자세히 보기',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Color(0xFFBDBDBD),
                          thickness: 1,
                        ),
                      ),
                      ListTile(
                        title: const Text('개인정보 처리 방침'),
                        trailing: TextButton(
                          onPressed: () {
                            dialog2();
                          },
                          child: const Text(
                            '자세히 보기',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                trailing: TextButton(
                  onPressed: () {
                    logout();
                  },
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAddFriendDialog(String userId) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            '친구 추가',
            style: TextStyle(fontSize: 18),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min, // 자식 위젯 크기만큼만 크기 설정
              children: [
                const Text(
                  '아래 QR 코드를 스캔하여 친구를 추가하세요.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
                ),
                const SizedBox(height: 16.0),
                QrImageView(
                  data: jsonEncode({"user_id": userId}), // QR 코드 데이터
                  version: QrVersions.auto, // QR 코드 버전 자동
                  size: 200.0, // QR 코드 크기
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '닫기',
                style: TextStyle(color: Color(0xFF18C971)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void navigateToFriendList(String userId) async {
    try {
      // 친구 목록 데이터를 가져옴
      final friends = await fetchFriends(userId);

      // 친구 목록을 다이얼로그로 표시
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              '친구 목록',
              style: TextStyle(fontSize: 18),
            ),
            content: SizedBox(
              height: 300,
              width: double.maxFinite,
              child: friends.isEmpty
                  ? const Center(
                child: Text("친구가 없습니다."),
              )
                  : ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: friend['profile_image'] != null
                          ? NetworkImage(friend['profile_image'])
                          : null,
                      child: friend['profile_image'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(friend['nickname'] ?? "Unknown"),
                    subtitle: Text(friend['email'] ?? ""),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  '닫기',
                  style: TextStyle(color: Color(0xFF18C971)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // 오류가 발생한 경우 처리
      print("Error displaying friend list: $e");
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              '에러',
              style: TextStyle(fontSize: 18),
            ),
            content: const Text("친구 목록을 불러오는 중 오류가 발생했습니다."),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  '닫기',
                  style: TextStyle(color: Color(0xFF18C971)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }


  void dialog1() async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            '이용약관 동의',
            style: TextStyle(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                SizedBox(height: 10),
                Text(
                  '수집 대상 개인정보'
                      '\n\n이 약관은 업체 회사(전자상거래 사업자)가 운영하는 업체 사이버 몰(이하 “몰”이라 한다)에서 제공하는 인터넷 관련 서비스(이하 “서비스”라 한다)를 이용함에 있어 사이버 몰과 이용자의 권리․의무 및 책임사항을 규정함을 목적으로 합니다.'
                      '\n※「PC통신, 무선 등을 이용하는 전자상거래에 대해서도 그 성질에 반하지 않는 한 이 약관을 준용합니다.」'
                      '\n\n개인정보 수집 목적'
                      '\n\n이 약관은 업체 회사(전자상거래 사업자)가 운영하는 업체 사이버 몰(이하 “몰”이라 한다)에서 제공하는 인터넷 관련 서비스(이하 “서비스”라 한다)를 이용함에 있어 사이버 몰과 이용자의 권리․의무 및 책임사항을 규정함을 목적으로 합니다.'
                      '\n※「PC통신, 무선 등을 이용하는 전자상거래에 대해서도 그 성질에 반하지 않는 한 이 약관을 준용합니다.」',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '확인',
                style: TextStyle(color: Color(0xFF18C971)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void dialog2() async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            '개인정보 처리 방침',
            style: TextStyle(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                SizedBox(height: 10),
                Text(
                  '제1조(목적)'
                      '\n\n이 약관은 업체 회사(전자상거래 사업자)가 운영하는 업체 사이버 몰(이하 “몰”이라 한다)에서 제공하는 인터넷 관련 서비스(이하 “서비스”라 한다)를 이용함에 있어 사이버 몰과 이용자의 권리․의무 및 책임사항을 규정함을 목적으로 합니다.'
                      '\n※「PC통신, 무선 등을 이용하는 전자상거래에 대해서도 그 성질에 반하지 않는 한 이 약관을 준용합니다.」'
                      '\n\n제2조(관리)'
                      '\n\n이 약관은 업체 회사(전자상거래 사업자)가 운영하는 업체 사이버 몰(이하 “몰”이라 한다)에서 제공하는 인터넷 관련 서비스(이하 “서비스”라 한다)를 이용함에 있어 사이버 몰과 이용자의 권리․의무 및 책임사항을 규정함을 목적으로 합니다.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '확인',
                style: TextStyle(color: Color(0xFF18C971)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void logout() async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            '  로그아웃 하시겠습니까?',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '취소',
                style: TextStyle(color: Color(0xFF999999)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '확인',
                style: TextStyle(color: Color(0xFF18C971)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onLogout();
              },
            ),
          ],
        );
      },
    );
  }
}
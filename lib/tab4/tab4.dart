import 'package:flutter/material.dart';

class Tab4 extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  const Tab4({required this.userInfo, super.key});

  @override
  _Tab4State createState() => _Tab4State();
}

class _Tab4State extends State<Tab4> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          Image.network(widget.userInfo['profile_image']),
          Text(widget.userInfo['nickname']),
      ],
    );
  }
}

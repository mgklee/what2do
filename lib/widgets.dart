import 'package:flutter/material.dart';

List<BottomNavigationBarItem> buildBottomNavigationItems(int selectedIndex) {
  return [
    BottomNavigationBarItem(
      icon: Icon(
        Icons.home,
        color: selectedIndex == 0
            ? const Color(0xFF0FD380)
            : const Color(0xFFBDBDBD),
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.location_on,
        color: selectedIndex == 1
            ? const Color(0xFF0FD380)
            : const Color(0xFFBDBDBD),
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.confirmation_num,
        color: selectedIndex == 3
            ? const Color(0xFF0FD380)
            : const Color(0xFFBDBDBD),
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.people,
        color: selectedIndex == 4
            ? const Color(0xFF0FD380)
            : const Color(0xFFBDBDBD),
      ),
      label: '',
    ),
  ];
}
/// 마이페이지에서 사용하는 공통 메뉴 타일 위젯.
import 'package:flutter/material.dart';

class MyPageMenuTile extends StatelessWidget {
  const MyPageMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }
}
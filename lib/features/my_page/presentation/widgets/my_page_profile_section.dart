/// 마이페이지 상단의 사용자 프로필 정보를 표시하는 위젯.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyPageProfileSection extends StatelessWidget {
  const MyPageProfileSection({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundImage:
          user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? const Icon(Icons.person_rounded, size: 40)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName!,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
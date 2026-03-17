/// 마이페이지에서 사용하는 다이얼로그들을 모아둔 파일.
import 'package:flutter/material.dart';

Future<bool?> showMyPageConfirmationDialog(
    BuildContext context, {
      required String title,
      required String content,
      required String confirmText,
    }) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmText,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

void showMyPageAppInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('앱 정보'),
      content: const Text('Nihongo v1.0.0\n\n개발자: rlaej'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}
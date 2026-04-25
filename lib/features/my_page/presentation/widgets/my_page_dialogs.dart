/// 마이페이지에서 사용하는 다이얼로그들을 모아둔 파일.
import 'package:flutter/material.dart';

Future<void> showFeedbackDialog(
  BuildContext context, {
  required Future<void> Function(String content) onSubmit,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _FeedbackDialog(onSubmit: onSubmit),
  );
}

class _FeedbackDialog extends StatefulWidget {
  const _FeedbackDialog({required this.onSubmit});

  final Future<void> Function(String content) onSubmit;

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('의견을 입력해주세요.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await widget.onSubmit(content);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('의견이 등록되었습니다. 감사합니다!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('의견 남기기'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: '의견을 입력해주세요.',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
        maxLength: 500,
        textAlignVertical: TextAlignVertical.top,
        enabled: !_isLoading,
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('등록'),
        ),
      ],
    );
  }
}

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

// void showMyPageAppInfoDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('앱 정보'),
//       content: const Text('Nihongo v1.0.0\n\n개발자: rlaej'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('확인'),
//         ),
//       ],
//     ),
//   );
// }